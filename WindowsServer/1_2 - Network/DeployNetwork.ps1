#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-vm

########-Common Variables-#########

#Names
$ResourceGroup          = "Terraria"
$Location               = "westeurope"
$NsRuleName             = "AllowInboundSubnetHome"

#IP
$SubnetAddressPrefix    = "192.168.1.0/24"
$VnetAddressPrefix      = "192.168.0.0/16"
$PublicIpName           = "publicIPaddress_03"

#Security
$IpToAllow              = "81.166.225.0/24"

#NIC
$NICName                = "NIC_03"
$NIC                    = Get-AzureRmNetworkInterface -ResourceGroupName "myResourceGroup" -Name $NICName -ErrorAction SilentlyContinue


$VnetName               = "vnet_03"
$SubnetName             = "Subnet_03"
$NsgName                = "NetWorkSecurityGroup_03"


####################################



####################################################################### 
####################################################################### 
#IP Mapping


#Subnet
$GetVnet = Get-AzureRmVirtualNetwork
If (!(Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $GetVnet)) {
    Write-Host "Creating new subnet config"
    $subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
        -Name $SubnetName `
        -AddressPrefix $SubnetAddressPrefix
}
Else {
    Write-Host "Using existing subnet config"
    $subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $GetVnet
}
   
   
   
#Virtual Network
If (!($GetVnet.Name -eq $VnetName)) {
    Write-Host "Creating new virtual network"
    $vnet = New-AzureRmVirtualNetwork `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name $VnetName `
        -AddressPrefix $VnetAddressPrefix `
        -Subnet $subnetConfig
    
}
Else {
    Write-Host "Using existing virtual network"
    $vnet = $GetVnet | Where-Object {$_.Name -eq $VnetName}
}

    

#Public IP  
$GetPublicIp = Get-AzureRmPublicIpAddress
If (!($GetPublicIp.Name -eq $PublicIpName)) {
    Write-Host "Creating new Public IP"
    $PublicIP = New-AzureRmPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -AllocationMethod Static `
        -Name $PublicIpName
}    
Else {
    Write-Host "Using existing Public IP"
    $PublicIP = $GetPublicIp | Where-Object {$_.Name -eq $PublicIpName}
}

    

    
####################################################################### 
####################################################################### 
# Network security
    

#Network Security Group    
$GetNSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Name $NsgName 

$GetNsgRule = Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $GetNSG

If (([string]::IsNullOrEmpty($GetNsgRule))) {
    #Network security rules
    #Inbound allow port 3389
    $NsgRule = New-AzureRmNetworkSecurityRuleConfig `
        -Name $NsRuleName `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 1000 `
        -SourceAddressPrefix $IpToAllow `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange * `
        -Access Allow
}
Else {
    Write-Output "Using existing security rule: $NsgName"
    $NsgRule = Set-AzureRmNetworkSecurityRuleConfig `
        -Name $NsRuleName -NetworkSecurityGroup $GetNSG
}



If (([string]::IsNullOrEmpty($GetNSG))) {
	$Nsg = New-AzureRmNetworkSecurityGroup `
		-ResourceGroupName $ResourceGroup `
		-Location $Location `
		-Name $NsgName `
		-SecurityRules $NsgRule
}    
Else {
	Write-Host "Using existing NetworkSecurityGroup: $GetNSG"
    $Nsg = $GetNSG
}
    
    
#Add NSG to subnet
Function SetSubnetConfig {
    Try {
        Set-AzureRmVirtualNetworkSubnetConfig `
            -Name $SubnetName `
            -VirtualNetwork $vnet `
            -NetworkSecurityGroup $Nsg `
            -AddressPrefix $SubnetAddressPrefix
        }
    Catch { 
        Write-Error $_
    }
}   

Function AssociateSecurityRuleToNIC {
    Try {
        Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $Nsg
    }
    Catch {
        Write-Error $_
        Exit
    }

    $NIC.NetworkSecurityGroup = $Nsg
    $NIC | Set-AzureRmNetworkInterface
}
    
    
####################################################################### 
####################################################################### 
#Network components    

Function CreateNetworkInterface {
    # Network interface card

	If (([string]::IsNullOrEmpty($NIC))) {
		Try {
            Write-Host "Creating new NIC"
			New-AzureRmNetworkInterface `
			-ResourceGroupName $ResourceGroup `
			-Location $Location `
			-Name $NICName `
			-SubnetId $vnet.Subnets[0].Id `
			-PublicIpAddressId $PublicIP.Id
		}
		Catch {
			Write-Error $_
		}
	}
	Else {
		Write-Host "Using existing NIC"
	}
}   
    
    
Function SetVirtualNetwork {
    Try {
        Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
    }
    Catch {
        Write-Error $_
    }
}    


CreateNetworkInterface
SetSubnetConfig
SetVirtualNetwork

AssociateSecurityRuleToNIC




