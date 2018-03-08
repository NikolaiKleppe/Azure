#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-vm    
#    Create virtual machine

#Server naming:
#AW = Azure Windows
#T  = Test environment

$cred = Get-Credential

#Variable number for:
# VM
# Disk
# Network Interface Card
$VmNumber = "03"


#OS
$ComputerName = "AW-T-$VmNumber"
$VMSize       = "Standard_A1"
#TODO: Change to Standard_B1S




#DISK
$DiskName       = "disk_$VmNumber"
$DiskSize       = "128"
$CreateOption   = "FromImage"
$Caching        = "ReadWrite"
$StorageAccount = "https://nikmystorageaccount.blob.core.windows.net/disks/"




#NETWORK
$NetworkInterfaceName = "NIC_$VmNumber"

#$NetworkInterfaceID  = Get-AzureRmNetworkInterface | Where-Object {$_.Name -eq $NetworkInterfaceName}
$NetworkInterfaceID   = Find-AzureRmResource -ResourceNameContains $NetworkInterfaceName
If ([string]::IsNullOrEmpty($NetworkInterfaceID)) {
    Write-Error "$NetworkInterfaceName does not exist, exiting"
    Exit
}




#RESOURCE GROUP
$ResourceGroupName = "myResourceGroup"
$ResourceGroup     = Get-AzureRmResourceGroup | Where-Object {$_.ResourceGroupName -eq $ResourceGroupName}





#Initial image settings
$vm = New-AzureRmVMConfig -VMName $ComputerName -VMSize $VMSize


 
#Operating system settings
$vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName $ComputerName `
    -Credential $cred `
    -ProvisionVMAgent -EnableAutoUpdate    

    
#Image settings    
$vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest
    
#Disk settings
$vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name $DiskName `
    -DiskSizeInGB $DiskSize `
    -CreateOption $CreateOption `
    -Caching $Caching

    
    
    
#Add NIC to VMdep   
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $NetworkInterfaceID.ResourceId



Try {
    Write-Output "Creating VM"
    New-AzureRmVM -ResourceGroupName $ResourceGroup.ResourceGroupName -Location "westeurope" -VM $vm -AsJob
    #See AsJob status with "Job"
}
Catch {
    Write-Error $_
    Exit
}












