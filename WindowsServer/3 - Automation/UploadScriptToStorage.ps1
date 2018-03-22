# 1) Upload script to storage
# 2) Configure VM to run the CSE (Set-AzureRmVMCustomScriptExtension)

#Container URI: https://nikmystorageaccount.blob.core.windows.net/csecontainer

$ScriptToUpload     = "SampleScript.ps1"
$StorageAccountName = "nikmystorageaccount"
$ResourceGroupName  = "myResourceGroup"
$ContainerName      = "csecontainer"


Set-AzureRmCurrentStorageAccount `
    -ResourceGroupName  $ResourceGroupName `
    -Name               $StorageAccountName 
    

#No need to create a new container each time we run the script.    
Function NewContainer {
    $GetContainer = Get-AzureStorageContainer | Where-Object {$_.Name -eq $ContainerName}
    If ([String]::IsNullOrEmpty($GetContainer)) {
        Write-Output "Creating new container: $ContainerName"
        New-AzureStorageContainer -Name $ContainerName
    }
    Else {
        Write-Output "Using existing container: $ContainerName"
    }
}
NewContainer

#Upload the file to container
Set-AzureStorageBlobContent `
    -File $ScriptToUpload `
    -Container $ContainerName






