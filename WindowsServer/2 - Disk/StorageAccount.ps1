#Need a storage account to create and manage disks

$ResourceGroupName = "myResourceGroup"

New-AzureRmStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -AccountName "nikmystorageaccount" `
    -Location "westeurope" `
    -SkuName Standard_RAGRS `
    -Kind Storage
    
    
    
#Storage information
<#
https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=powershell

https://docs.microsoft.com/en-us/azure/storage/common/storage-create-storage-account


https://nikmystorageaccount.blob.core.windows.net/disks/   
    
    
    
    
#>
