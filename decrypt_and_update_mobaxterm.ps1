# PowerShell script to run the bash script in MobaXterm
# This script will open MobaXterm and execute the decrypt script

$scriptPath = Join-Path $PSScriptRoot "decrypt_and_update.sh"
$repoPath = $PSScriptRoot

Write-Host "To run the decryption script in MobaXterm:"
Write-Host "1. Open MobaXterm"
Write-Host "2. Navigate to: $repoPath"
Write-Host "3. Run: bash decrypt_and_update.sh"
Write-Host ""
Write-Host "Or run this command in MobaXterm:"
Write-Host "cd '$repoPath' && bash decrypt_and_update.sh"

