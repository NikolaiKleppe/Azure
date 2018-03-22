
Param(
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$GroupName
)

$MailNickName = "$($GroupName)$('Alias')"

$ADGroup = New-AzureADGroup -DisplayName $GroupName `
    -MailNickName $MailNickName `
    -MailEnabled $False `
    -SecurityEnabled $True

    
    
    
    