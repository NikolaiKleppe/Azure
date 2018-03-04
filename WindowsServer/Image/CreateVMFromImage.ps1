$Credential         = Get-Credential -Message "Enter a username and password for the virtual machine."

$VMName             = "AW-T-04"
$VMSize             = "Standard_A1"
$ImageName          = "GeneralPurposeVm"
$ResourceGroupName  = "myResourceGroup"
$Location           = "westeurope"

#Network interface card to attach the vm to
$NICName = "NIC_04"
$NIC = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICName -ErrorAction SilentlyContinue

If (([string]::IsNullOrEmpty($NIC))) {
    Write-Output "Can't find NIC: $NICName"
    Exit
}


$VmConfig = New-AzureRmVMConfig `
    -VMName $VMName `
    -VMSize $VMSize | Set-AzureRmVMOperatingSystem -Windows `
        -ComputerName $VMName `
        -Credential $Credential

Try {        
    $Image = Get-AzureRmImage `
        -ImageName $ImageName `
        -ResourceGroupName $ResourceGroupName
}
Catch {
    Write-Error $_
    Exit
}
    
$VmConfig = Set-AzureRmVMSourceImage -VM $VmConfig -Id $Image.Id
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -Id $NIC.Id    


New-AzureRmVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $VmConfig
