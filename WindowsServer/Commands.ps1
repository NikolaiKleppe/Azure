#Mostly Get commands for retrieving info.

########################################
#OVERVIEW / SUBSCRIPTION / AVAILABILITY#

#Get available resources to use
    Get-AzureRmComputeResourceSku | where {$_.Name.Contains("Standard_A1")}
    Get-AzureRmComputeResourceSku | Where-Object {$_.Name -eq "Standard_A1"}

#Get SKU for a region 
    Get-AzureRmComputeResourceSku | where {$_.Locations.Contains("westeurope")} 
    http://www.itprotoday.com/microsoft-azure/how-can-i-check-vm-sizes-available-certain-azure-region

#Get resource groups
    Get-AzureRmResourceGroup
    

########################################
# NETWORK #

#Get NIC settings
   Get-AzureRmNetworkInterface

#Get all network settings for a specific virtual network
    Get-AzureRmVirtualNetwork | where {$_.Name -eq "vnet_01"}


#Get public IP adress for all computers in a resource group
    Get-AzureRmPublicIpAddress -ResourceGroupName myResourceGroup  | Select Name, IpAddress




########################################
# Virtual Machines #

#Get all computers
    Get-AzureRmVM


#RDP to VM
    mstsc /v:<publicIpAddress>
    mstsc /v:

########################################
# IMAGE #

#Get available pre-built images
    Get-AzureRmVMImageSku -Location "westeurope" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"


#Get a list of VM sizes available in a particular region    
    
    Get-AzureRmVMSize -Location "westeurope"
    
    
    
#Get created images
$images = Find-AzureRMResource -ResourceType Microsoft.Compute/images 
$images.name


    
    
    
    
    
    
    
    
    
    
    
    