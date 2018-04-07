
#Adds NIC to existing Security Group, which can contain multuple rule sets.
#https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-nsg-arm-ps

$IpToAllow              = "195.204.41.0/24"


$NsRuleName             = "AllowInboundWork"
$Direction 				= "Inbound"
$NSGName                = "NetworkSecurityGroup_03"

$SubnetName             = "Subnet_01"
$SubnetAddressPrefix    = "192.168.1.0/24"

$VnetName               = "vnet_03"
$vnet                   = Get-AzureRmVirtualNetwork | Where-Object {$_.Name -eq $VnetName}

$ResourceGroupName      = "Terraria"

$NICName                = "NIC_03"
$NIC                    = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICName



#Network Security Group    
Try {
    $NSG = Get-AzureRmNetworkSecurityGroup | Where-Object {$_.Name -eq $NSGName} -ErrorAction Stop
}
Catch {
    Write-Error $_
    Exit
}


#Change <Add-> to <Set-> to change the rule instead
Try {
    $NsRule = Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
        -Name $NsRuleName `
        -Protocol Tcp `
        -Direction $Direction `
        -Priority 900 `
        -SourceAddressPrefix $IpToAllow `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange * `
        -Access Allow
}
Catch {
    Write-Error $_
    Exit
}    

    

#Add NSG to subnet
Function SetSubnetConfig {
    Try {
		Set-AzureRmVirtualNetworkSubnetConfig `
			-Name $SubnetName `
			-VirtualNetwork $vnet `
			-NetworkSecurityGroup $NSG `
			-AddressPrefix $SubnetAddressPrefix
	}
	Catch {
		Write-Error $_
		Exit
	}
} 

#SetSubnetConfig
#Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

#https://docs.microsoft.com/en-us/powershell/module/azurerm.network/set-azurermnetworkinterface?view=azurermps-5.2.0
Try {
	Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $NSG
}
Catch {
	Write-Error $_
	Exit
}

$NIC.NetworkSecurityGroup = $NSG
$NIC | Set-AzureRmNetworkInterface










