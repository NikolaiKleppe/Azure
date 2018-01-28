#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-vm

########-Common Variables-#########

#Names
$ResourceGroup = "myResourceGroup"
$Location      = "westeurope"

#Network
$SubnetAddressPrefix = "192.168.1.0/24"
$VnetAddressPrefix   = "192.168.0.0/16"

$NICName             = "NIC_01"
$VnetName            = "vnet_01"
$PublicIpName        = "publicIPaddress_01"
$SubnetName          = "Subnet_01"
$NsgName             = "NetWorkSecurityGroup_01"

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
    


#Network security rules
#Inbound allow port 3389
$NsgRule = New-AzureRmNetworkSecurityRuleConfig `
    -Name NSGRule_01 `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1000 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389 `
    -Access Allow
    


#Network Security Group    
$GetNSG = Get-AzureRmNetworkSecurityGroup

If (!($GetNSG.Name -eq $NsgName)) {
	$Nsg = New-AzureRmNetworkSecurityGroup `
		-ResourceGroupName $ResourceGroup `
		-Location $Location `
		-Name $NsgName `
		-SecurityRules $NsgRule
}    
Else {
	Write-Host "Using existing NetworkSecurityGroup"
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
    
    
####################################################################### 
####################################################################### 
#Network components    

Function CreateNetworkInterface {
    # Network interface card
	$GetNIC = Get-AzureRmNetworkInterface
	If (!($GetNIC.Name -eq $NICName)) {
		Try {
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
#Dont think we need if check here, as it just updates the network settings instead of creating then.
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






















































































































