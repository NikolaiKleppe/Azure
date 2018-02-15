#Creates a disk for use with a Windows Virtual Machine and adds it to a specific VM.
    #https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-data-disk
    
    
$DiskNumber         = "03-02"       #Temp, 2nd disk of AW-T-03
$VmName             = "AW-T-03"  
    
$Location           = "westeurope" 
$CreateOptionConfig = "Empty"   
$DiskSizeGB         = "128"

$ResourceGroupName  = "myResourceGroup"
$Diskname           = "disk_$DiskNumber"    
$CreateOption       = "Attach"
    
    
$DiskConfig = New-AzureRmDiskConfig `
    -Location $Location `
    -CreateOption $CreateOptionConfig `
    -DiskSizeGB $DiskSizeGB
    

Try {
    $GetDisk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName
}
Catch {
    Write-Error $_
    Write-Error "Exiting script"
    Exit
}


If (!([string]::IsNullorEmpty($GetDisk))) {
    $DataDisk = New-AzureRmDisk `
        -ResourceGroupName $ResourceGroupName `
        -DiskName $DiskName `
        -Disk $DiskConfig
}  
Else {
    "Disk already exists, attaching if it isn't already attached to a VM."
}  

    
    
#The VM we want to add the disk to
Try {
    $vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName    
}
Catch {
    Write-Error $_
    Exit
}


#Add the data disk to the virtual machine configuration
Try {
    $vm = Add-AzureRmVMDataDisk `
        -VM $vm `
        -Name $DiskName `
        -CreateOption $CreateOption `
        -ManagedDiskId $DataDisk.Id `
        -Lun 1
}
Catch {
    Write-Error $_
    Exit
}   


   
Try {
    Write-Output "Adding disk $DiskName to $VmName"
    Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
}   
Catch {
    Write-Error $_
    Exit
}
   
   
   
#TODO: Prepare data disks
   
   
   
   
   
   