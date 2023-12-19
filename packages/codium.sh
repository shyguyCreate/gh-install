#!/bin/sh

package_name="codium"
repo="VSCodium/vscodium"
package_type="app"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match by architecture
download_x64='VSCodium-linux-x64-.*\.tar\.gz'
download_arm32='VSCodium-linux-armhf-.*\.tar\.gz'
download_arm64='VSCodium-linux-arm64-.*\.tar\.gz'
download_x32=''

#Specify that file has checksums with same filename
hash_extension='sha256'

#Path to binary based on download (start with ./)
bin_package="./bin/$package_name"

#Path to completion file based on download (start with ./)
bash_completion="./resources/completions/bash/${package_name}"
zsh_completion="./resources/completions/zsh/_${package_name}"

#Path to image file based on download (start with ./)
local_desktop_image="./resources/app/resources/linux/code.png"

#Should package be started in terminal
is_terminal=false

#Source file with functions
. "$installer_dir/.install.sh"
