#!/bin/sh

#Name to identify package
package_name="yay"

#Specify github repo like this "owner/repo-name"
package_repo="Jguer/yay"

#Specify type of package (app|bin|font)
package_type="bin"

#Regex match for package for specific architecture
package_for_x64="yay_.*_x86_64\.tar\.gz"
package_for_arm64="yay_.*_aarch64\.tar\.gz"
package_for_arm32="yay_.*_armv7h\.tar\.gz"
package_for_x32=""

#Remove num of leading folders in tar archive
strip_components=1

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Path to completion file based on download (start with ./)
bash_completion="./bash"
zsh_completion="./zsh"
fish_completion="./fish"
