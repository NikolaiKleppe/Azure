
#Adds to existing Security Group, which can contain multuple rule sets.
#https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-nsg-arm-ps

$IpToAllow              = "81.166.225.0/24"


$NsRuleName             = "AllowInboundSubnetHome"
$NSGName                = "NetworkSecurityGroup_01"

$SubnetName             = "Subnet_01"
$SubnetAddressPrefix    = "192.168.1.0/24"

$VnetName               = "vnet_01"
$vnet                   = Get-AzureRmVirtualNetwork | Where-Object {$_.Name -eq $VnetName}

$NICName                = "NIC_01"
$NIC                    = Get-AzureRmNetworkInterface -ResourceGroupName "myResourceGroup" -Name $NICName



#Network Security Group    
$NSG = Get-AzureRmNetworkSecurityGroup | Where-Object {$_.Name -eq $NSGName} 


#Change <Add-> to <Set-> to change the rule instead
$NsRule = Set-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
    -Name $NsRuleName `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1000 `
    -SourceAddressPrefix $IpToAllow `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange * `
    -Access Allow

    

#Add NSG to subnet
Function SetSubnetConfig {
    Set-AzureRmVirtualNetworkSubnetConfig `
        -Name $SubnetName `
        -VirtualNetwork $vnet `
        -NetworkSecurityGroup $NSG `
        -AddressPrefix $SubnetAddressPrefix
} 

#SetSubnetConfig
#Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

#https://docs.microsoft.com/en-us/powershell/module/azurerm.network/set-azurermnetworkinterface?view=azurermps-5.2.0
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $NSG

$NIC.NetworkSecurityGroup = $NSG
$NIC | Set-AzureRmNetworkInterface










