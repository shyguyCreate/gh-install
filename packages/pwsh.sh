#!/bin/sh

package_name="pwsh"
repo="PowerShell/PowerShell"
package_type="app"

#Save path to root of the repo
repo_dir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repo_dir/.check-install.sh"

#Regex match by architecture
download_x64='powershell-.*-linux-x64\.tar\.gz'
download_arm32='powershell-.*-linux-arm32\.tar\.gz'
download_arm64='powershell-.*-linux-arm64\.tar\.gz'
download_x32=''

#Specify filename with checksums
hash_file='hashes.sha256'

#Download release file
. "$repo_dir/.download.sh"

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Url for application image
online_image="https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"

#Add desktop file to system
need_desktop_file=true
is_terminal=true

#Source file with functions
. "$repo_dir/.install.sh"
