<#
.SYNOPSIS
    This Bash script ensures that any version of libcurl gets updated to the latest version. (currently 8.9.1)

.NOTES
    Author          : Simon VanLeuven
    LinkedIn        : linkedin.com/in/simon-vanleuven/
    GitHub          : github.com/vanleu22
    Date Created    : 2025-02-04
    Last Modified   : 2025-02-17
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : N/A
 
.TESTED ON
    Date(s) Tested  : 2025-02-04
    Tested By       : Simon VanLeuven
    Systems Tested  : Linux (ubuntu 22.04)
    PowerShell Ver. : N/A
.USAGE
    Create Nano update_curl.sh 
    copy/paste the below script and save
    
    Example syntax:
    PS C:\> chmod +x update_curl.sh    
    PS C:\> ./update_curl.sh
#>

# YOUR CODE GOES HERE

#!/bin/bash

# Ensure the package list is updated
sudo apt update

# Remove the old version of libcurl (if necessary)
sudo apt remove libcurl3 -y

# Install required dependencies for building curl
sudo apt install -y build-essential libssl-dev

# Set the latest version of curl
latestCurlVersion="8.9.1"
downloadUrl="https://curl.se/download/curl-$latestCurlVersion.tar.gz"
downloadPath="/tmp/curl-$latestCurlVersion.tar.gz"

# Download the latest version of curl
wget -O $downloadPath $downloadUrl || { echo "Download failed"; exit 1; }

# Extract the downloaded file
extractPath="/tmp/curl-$latestCurlVersion"
tar -xzvf $downloadPath -C /tmp || { echo "Extraction failed"; exit 1; }

# Navigate to the extracted directory
cd $extractPath || { echo "Failed to change directory"; exit 1; }

# Check if configure file exists
if [ ! -f configure ]; then
    echo "Configure script not found. Checking subdirectories..."
    configure_path=$(find . -name "configure" | head -n 1)
    if [ -z "$configure_path" ]; then
        echo "Configure script not found in any subdirectory."
        exit 1
    else
        echo "Found configure script at: $configure_path"
        cd $(dirname $configure_path) || exit
    fi
fi

# Make configure script executable 
chmod +x configure

# Configure, compile, and install
./configure --prefix=/usr/local --with-ssl || { echo "Configuration failed"; exit 1; }
make || { echo "Make failed"; exit 1; }
sudo make install || { echo "Installation failed"; exit 1; }

# Update the dynamic linker run-time bindings
sudo ldconfig

# Verify the installation
curl --version
