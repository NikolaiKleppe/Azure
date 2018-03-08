#Testing from tutorial
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-availability-sets


. ../CommonVariables.ps1
    
$cred = Get-Credential    
    
for ($i=5; $i -le 6; $i++)
{
    New-AzureRmVm `
        -ResourceGroupName $ResourceGroupName `
        -Name "AW-T-0$i" `
        -Location $Location `
        -VirtualNetworkName $VnetName `
        -SubnetName $SubnetName `
        -SecurityGroupName $NsgName `
        -PublicIpAddressName "myPublicIpAddress$i" `
        -AvailabilitySetName "AvailabilitySet_1" `
        -Credential $cred `
        -AsJob
        
}


#AvailabilitySetName doesnt work....?
#New-AzureRmVM : A parameter cannot be found that matches parameter name 'AvailabilitySetName'.