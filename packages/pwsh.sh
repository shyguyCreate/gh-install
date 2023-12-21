#!/bin/sh

#Name to identify package
package_name="pwsh"

#Specify github repo like this "owner/repo-name"
package_repo="PowerShell/PowerShell"

#Specify type of package (app|bin|font)
package_type="app"

#Regex match for package for specific architecture
package_for_x64="powershell-.*-linux-x64\.tar\.gz"
package_for_arm64="powershell-.*-linux-arm64\.tar\.gz"
package_for_arm32="powershell-.*-linux-arm32\.tar\.gz"
package_for_x32=""

#Regex match for filename with hash
hash_file="hashes.sha256"

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Online url for application image
online_desktop_image="https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"
#Should package be started in terminal (true|false)
is_terminal=true
