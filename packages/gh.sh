#!/bin/sh

package_name="gh"
repo="cli/cli"
package_type="bin"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match by architecture
download_x64='gh_.*_linux_amd64\.tar\.gz'
download_arm32='gh_.*_linux_armv6\.tar\.gz'
download_arm64='gh_.*_linux_arm64\.tar\.gz'
download_x32='gh_.*_linux_386\.tar\.gz'

#Specify filename with checksums
hash_file='gh_.*_checksums.txt'
#Specify hash algorithm when not found in extension
hash_algorithm='sha256'

#Remove num of leading folders in tar archive
strip_components=1

#Path to binary based on download (start with ./)
bin_package="./bin/$package_name"

#Completions for bash/zsh/fish using Cobra completion command
cobra_completion="old"

#Source file with functions
. "$installer_dir/.install.sh"
