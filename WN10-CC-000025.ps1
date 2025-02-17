# This script downloads and configures the MSS-Legacy templates for IP Source Routing protection on Windows 10 systems.

# Define paths for the ADMX and ADML files
$admxPath = "C:\Windows\PolicyDefinitions\MSS-Legacy.admx"
$admlPath = "C:\Windows\PolicyDefinitions\en-US\MSS-Legacy.adml"

# URL where the STIG package can be found (adjust if the URL changes)
$stigPackageUrl = "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_STIG_GPO_Package_January_2025.zip"

# Temporary download path
$tempDownloadPath = "$env:TEMP\STIG_Package.zip"

# Check if the directory exists, if not, create it
if (-not (Test-Path "C:\Windows\PolicyDefinitions")) {
    New-Item -ItemType Directory -Path "C:\Windows\PolicyDefinitions"
}

if (-not (Test-Path "C:\Windows\PolicyDefinitions\en-US")) {
    New-Item -ItemType Directory -Path "C:\Windows\PolicyDefinitions\en-US"
}

# Download and unzip the STIG package
try {
    Write-Output "Downloading STIG package..."
    Invoke-WebRequest -Uri $stigPackageUrl -OutFile $tempDownloadPath
    Write-Output "Extracting MSS-Legacy templates..."
    Expand-Archive -Path $tempDownloadPath -DestinationPath $env:TEMP\STIG_Unzipped -Force

    # Copy .admx and .adml files to their respective directories
    Copy-Item "$env:TEMP\STIG_Unzipped\MSS-Legacy.admx" -Destination $admxPath -Force
    Copy-Item "$env:TEMP\STIG_Unzipped\MSS-Legacy.adml" -Destination $admlPath -Force

    Write-Output "MSS-Legacy templates have been placed in the correct directories."
} catch {
    Write-Error "Failed to download or extract STIG package. Error: $_"
    exit
}

# Clean up temporary files
Remove-Item $tempDownloadPath -Force -ErrorAction SilentlyContinue

# Import the Group Policy module if not already loaded
if (-not (Get-Module -ListAvailable -Name GroupPolicy)) {
    Write-Output "Importing Group Policy module..."
    Import-Module GroupPolicy
}

# Set the policy value for DisableIPSourceRouting to 'Highest protection, source routing is completely disabled'
# The value 2 corresponds to "Highest protection, source routing is completely disabled"
try {
    Set-GPRegistryValue -Name "Local Computer Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\MSS" -ValueName "DisableIPSourceRouting" -Type DWord -Value 2
    Write-Output "Successfully set DisableIPSourceRouting to the highest protection level."
} catch {
    Write-Error "Failed to set the policy. Error: $_"
}

# Optionally, refresh the group policy to apply changes immediately
try {
    gpupdate /force
    Write-Output "Group Policy updated to apply changes."
} catch {
    Write-Error "Failed to update Group Policy. Error: $_"
}
