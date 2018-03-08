
. ../CommonVariables.ps1


New-AzureRmAvailabilitySet `
    -Location $Location `
    -Name "AvailabilitySet_1" `
    -ResourceGroupName $ResourceGroup `
    -Sku aligned `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 2

