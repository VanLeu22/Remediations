<#
.SYNOPSIS
    This PowerShell script ensures that the guest account is disabled.

.NOTES
    Author          : Simon VanLeuven
    LinkedIn        : linkedin.com/in/simon-vanleuven/
    GitHub          : github.com/vanleu22
    Date Created    : 2025-02-18
    Last Modified   : 2025-02-18
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000010

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Simon VanLeuven
    Systems Tested  : Windows 10 Pro
    PowerShell Ver. : 

.USAGE
   #>

# Get the Guest user account
$guestAccount = Get-WmiObject -Class Win32_UserAccount -Filter "Name='Guest' AND LocalAccount=True"

if ($guestAccount) {
    # Disable the account if it's not already disabled using net user command
    $disableCmd = "net user Guest /active:no"
    $result = Invoke-Expression $disableCmd
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Guest account has been disabled successfully."
    } else {
        Write-Host "Failed to disable the Guest account. Return value: $LASTEXITCODE"
    }

    # Ensure the account cannot be enabled by setting the AccountDisabled flag in the registry
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set or verify the Guest account status in the registry
    if (!(Get-ItemProperty -Path $regPath -Name "Guest" -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $regPath -Name "Guest" -Value 0 -PropertyType DWord -Force
        Write-Host "Registry entry for Guest account set to disable."
    } else {
        Set-ItemProperty -Path $regPath -Name "Guest" -Value 0 -Force
        Write-Host "Registry entry for Guest account updated to ensure it's disabled."
    }
} else {
    Write-Host "Guest account not found."
}

Write-Host "Script execution completed."
