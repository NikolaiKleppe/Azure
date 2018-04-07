#Create container
#upload files to container

Param(
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$File
)

$ContainerName     = "mycontainer"
$StorageName       = "nikblobstorage"
$ResourceGroupName = "blobs" 
$Location          = "westeurope"



Try {
    $temp = Get-AzureRmStorageAccount -Name $StorageName -ResourceGroup $ResourceGroupName
    $ctx  = $temp.Context
}
Catch {
    Write-Error $_
    Exit
}



$temp = Get-AzureStorageContainer -Name $ContainerName -Context $ctx -ErrorAction SilentlyContinue
If (!($?)) {
    Write-Output "Creating new container"
    New-AzureStorageContainer -Name $ContainerName -Context $ctx -Permission blob
}
Else {
    Write-Output "Using existing container: $ContainerName"
}



Function UploadFile ($File) {
    Try {
        Set-AzureStorageBlobContent -File $File `
            -Container $ContainerName `
            -Context $ctx
            
        Write-Output "Uploaded file $File to container"
    }
    Catch {
        Write-Error $_
        Exit
     }
}


UploadFile $File




Function DisplayStorage {
    Get-AzureStorageBlob -Container $ContainerName -Context $ctx | select Name 
}
#DisplayStorage
