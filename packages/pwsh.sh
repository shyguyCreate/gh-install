#!/bin/sh

package_name="pwsh"
repo="PowerShell/PowerShell"
package_type="bin"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match by architecture
download_x64='powershell-.*-linux-x64\.tar\.gz'
download_arm32='powershell-.*-linux-arm32\.tar\.gz'
download_arm64='powershell-.*-linux-arm64\.tar\.gz'
download_x32=''

#Specify filename with checksums
hash_file='hashes.sha256'

#Download release file
. "$repoDir/.download.sh"

#Source file with functions
. "$repoDir/.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "$installDir/$package_name"

#Uninstall old package version
uninstall_old_version

#Add image file to system (local|onine) (image-location|url)
add_image_file "online" "https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"

#Add desktop file to system (true|false for terminal application)
add_desktop_file true
