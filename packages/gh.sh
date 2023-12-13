#!/bin/sh

package_name="gh"
repo="cli/cli"
package_type="bin"

#Save path to root of the repo
repo_dir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repo_dir/.check-install.sh"

#Regex match by architecture
download_x64='gh_.*_linux_amd64\.tar\.gz'
download_arm32='gh_.*_linux_armv6\.tar\.gz'
download_arm64='gh_.*_linux_arm64\.tar\.gz'
download_x32='gh_.*_linux_386\.tar\.gz'

#Specify filename with checksums
hash_file='gh_.*_checksums.txt'
#Specify hash algorithm when not found in extension
hash_algorithm='sha256'

#Download release file
. "$repo_dir/.download.sh"

#Remove num of leading folders in tar archive
strip_components=1
#Path to binary based on download (start with ./)
bin_package="./bin/$package_name"

#Source file with functions
. "$repo_dir/.install.sh"

#Add completion file for bash/zsh/fish (completion-location)
add_completions "old-Cobra"
