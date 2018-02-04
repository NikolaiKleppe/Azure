#Open PowerShell and login to Azure

$DesktopPath = [Environment]::GetFolderPath("Desktop")

PowerShell.exe -NoExit Select-AzureRmProfile -Path "$DesktopPath\Azure\WindowsServer\Creds\AzureProfile.json"

