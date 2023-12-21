#!/bin/sh

#Name to identify package
package_name="codium"

#Specify github repo like this "owner/repo-name"
package_repo="VSCodium/vscodium"

#Specify type of package (app|bin|font)
package_type="app"

#Regex match for package for specific architecture
package_for_x64="VSCodium-linux-x64-.*\.tar\.gz"
package_for_arm64="VSCodium-linux-arm64-.*\.tar\.gz"
package_for_arm32="VSCodium-linux-armhf-.*\.tar\.gz"
package_for_x32=""

#Hashes are in same filename as download match plus extension
hash_extension="sha256"

#Path to binary based on download (start with ./)
bin_package="./bin/$package_name"

#Path to completion file based on download (start with ./)
bash_completion="./resources/completions/bash/${package_name}"
zsh_completion="./resources/completions/zsh/_${package_name}"

#Path to image file based on download (start with ./)
local_desktop_image="./resources/app/resources/linux/code.png"
#Should package be started in terminal (true|false)
is_terminal=false
