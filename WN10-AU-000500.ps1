<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Simon VanLeuven
    LinkedIn        : linkedin.com/in/simon-vanleuven/
    GitHub          : github.com/VanLeu22
    Date Created    : 2025-02-10
    Last Modified   : 2025-02-10
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  : 2025-02-10
    Tested By       : Simon VanLeuven
    Systems Tested  : Windows 10
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-AU-000500.ps1 
#> 



# Ensure you're running PowerShell with administrative privileges

# Define the registry path and value
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$regValueName = "MaxSize"
$regValueData = 0x8000  # This is equivalent to 32768 in decimal

# Check if the key exists, if not, create it
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the registry value
Set-ItemProperty -Path $regPath -Name $regValueName -Value $regValueData -Type DWord -Force

# Verify the setting (optional)
Get-ItemProperty -Path $regPath

