
$StorageName       = "nikblobstorage"
$ResourceGroupName = "blobs" 

$Location           = "westeurope"

$temp = Get-AzureRmResourceGroup -name $ResourceGroupName -ErrorAction SilentlyContinue
If (!($?)) {
    Write-Output "Creating new resource  group"
    New-AzureRmResourceGroup -name $ResourceGroupName -Location $Location
}


$temp = Get-AzureRmStorageAccount -Name $StorageName -ResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue
If (!($?)) {
    Write-Output "Creating new Storage Account"
    $StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
        -Name $StorageName `
        -Location $Location `
        -SkuName Standard_LRS `
        -Kind Storage
        
    $ctx = $StorageAccount.Context    
    
}    
Else {
    $ctx = $temp.Context
}



