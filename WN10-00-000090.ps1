<#
.SYNOPSIS
    This PowerShell script modifies registry settings for password expiration and ensures that all local user accounts have passwords set to expire.

.NOTES
    Author          : Simon VanLeuven
    LinkedIn        : linkedin.com/in/simon-vanleuven/
    GitHub          : github.com/vanleu22
    Date Created    : 2025-02-18
    Last Modified   : 2025-02-18
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-00-000090

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Simon VanLeuven
    Systems Tested  : Windows 10 Pro
    PowerShell Ver. : 

.USAGE
 
# Note: This script must be run with administrative privileges
#>

# Import the ADSI module for better control over user account settings
Import-Module ActiveDirectory

# Get all local user accounts
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"

foreach ($user in $users) {
    try {
        # Check if the user account is enabled
        if ($user.Disabled -eq $false) {
            # Use ADSI to get the user object
            $userADSI = [ADSI]"WinNT://./$($user.Name),user"
            
            # Retrieve the 'UserFlags' to check and modify password policy
            $userFlags = $userADSI.UserFlags.Value
            
            # Check if 'Password Never Expires' is set (bit 16 in UserFlags)
            if (($userFlags -band 0x10000) -eq 0x10000) {
                Write-Host "Password for $($user.Name) will be set to expire."
                # Remove the 'Password Never Expires' flag
                $userADSI.UserFlags.Value = $userFlags -band (-bnot 0x10000)
                $userADSI.SetInfo()
                Write-Host "Password expiration for $($user.Name) has been updated."
            } else {
                Write-Host "Password for $($user.Name) is already set to expire."
            }
        } else {
            Write-Host "$($user.Name) is disabled. Skipping."
        }
    } catch {
        Write-Host "An error occurred while processing $($user.Name): $_"
    }
}

Write-Host "Password expiration policy check completed."
