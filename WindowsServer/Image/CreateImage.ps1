#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-custom-images
#Requirements:
#First do a sysprep on the VM. (Ref doc)

#Deallocates VM
#Set VM status to generalized
#Create image



Param(
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$ComputerName
)


$ErrorActionPreference 	= "Stop"
$ResourceGroup 			= "myResourceGroup"
$ImageName				= "GeneralPurposeVm"




Stop-AzureRmVM -ResourceGroupName $ResourceGroup -Name $ComputerName -Force
Set-AzureRmVM -ResourceGroupName $ResourceGroup -Name $ComputerName -Generalized


$GetVM = Get-AzureRmVM -Name $ComputerName -ResourceGroupName $ResourceGroup
If (!($GetVM)) {
	Write-Output "Cant find VM named $ComputerName"
	Exit
}

Write-Output "Creating image configuration.."
Try {
		$Image = New-AzureRmImageConfig -Location "westeurope" -SourceVirtualMachineId $GetVM.ID
		Write-Output "Image configuration done"
		Write-Output ""
}
Catch {
	Write-Error $_
	Exit
}

Try {	
		Write-Output "Creating the image from config"
		New-AzureRmImage -Image $Image -ImageName $ImageName -ResourceGroupName $ResourceGroup
		Write-Output "Image $ImageName created successfully"
}
Catch {
	Write-Error $_
	Exit
}













