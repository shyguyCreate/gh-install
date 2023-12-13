#!/bin/sh

package_name="codium"
repo="VSCodium/vscodium"
package_type="app"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match by architecture
download_x64='VSCodium-linux-x64-.*\.tar\.gz'
download_arm32='VSCodium-linux-armhf-.*\.tar\.gz'
download_arm64='VSCodium-linux-arm64-.*\.tar\.gz'
download_x32=''

#Specify that file has checksums with same filename
hash_extension='sha256'

#Download release file
. "$repoDir/.download.sh"

#Uninstall old package version
. "$repoDir/.uninstall.sh"

#Set path to binary based on the downloaded file
bin_package="./bin/$package_name"

#Source file with functions
. "$repoDir/.install.sh"

#Add completion file for bash/zsh/fish (completion-location)
add_completions "bash" "$installDir/resources/completions/bash/$package_name"
add_completions "zsh" "$installDir/resources/completions/zsh/_$package_name"

#Add image file to system (local|onine) (image-location|url)
add_image_file "local" "$installDir/resources/app/resources/linux/code.png"

#Add desktop file to system (true|false for terminal application)
add_desktop_file false
