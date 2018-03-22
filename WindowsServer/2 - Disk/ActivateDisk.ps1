#After creating a disk and adding it to the VM (CreateDiskAndAttach.ps1) we need to make the OS use  the disk.
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-data-disk
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-automate-vm-deployment
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-features


#Manually in the VM or with Azure Custom Script Extension (from anywhere)

#https://blogs.technet.microsoft.com/stefan_stranger/2017/07/31/using-azure-custom-script-extension-to-execute-scripts-on-azure-vms/





#https://blog.azureandbeyond.com/2017/01/04/custom-script-extensions/



Param(
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$VMName
)



#$Settings = '{"CommandToExecute":"powershell Get-Process | Out-File -filePath C:\process.txt"}'
$Settings = @{
    "commandToExecute" = "powershell Get-Process | Out-File -filePath C:\process.txt"
}

Set-AzureRmVMExtension -ResourceGroupname "myResourceGroup" `
    -Publisher "Microsoft.Compute" `
    -VMName $VMName `
    -ExtensionType CustomScriptExtension `
    -Settings $Settings
    
    
    








