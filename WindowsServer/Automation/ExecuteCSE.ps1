
#Run/Execute a script uploaded with 'UploadScriptToStorage.ps1' on a VM.

Param(
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$FileName, #IMPORTANT: This is the STRING/Name of the script, not the file itself. 
    
    [Parameter(Mandatory=$True, Position=2)] 
    [string]$VMName
)


$CseName            = "TestScript"
$ContainerName      = "csecontainer"
$StorageAccountName = "nikmystorageaccount"
$ResourceGroupName  = "myResourceGroup"
$Location           = "westeurope"


Set-AzureRmVMCustomScriptExtension `
    -Name $CseName `
    -ContainerName $ContainerName `
    -FileName $FileName `
    -StorageAccountName $StorageAccountName `
    -ResourceGroupName $ResourceGroupName `
    -VMName $VMName `
    -Run $FileName `
    -Location $Location

