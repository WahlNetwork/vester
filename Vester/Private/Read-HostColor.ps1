# Used in New-VesterConfig to better highlight user prompts
function Read-HostColor ($Text) {
    Write-Host $Text -ForegroundColor Yellow -NoNewline
    Write-Output (Read-Host ' ')
}
