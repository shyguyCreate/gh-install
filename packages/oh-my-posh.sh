#!/bin/sh

package_name="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
package_type="bin"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match by architecture
download_x64='posh-linux-amd64'
download_arm32='posh-linux-arm'
download_arm64='posh-linux-arm64'
download_x32='posh-linux-386'

#Specify that file has checksums with same filename
hash_extension='sha256'

#Download release file
. "$repoDir/.download.sh"

#Uninstall old package version
. "$repoDir/.uninstall.sh"

bin_package="./$package_name"

#Source file with functions
. "$repoDir/.install.sh"

#Add completion file for bash/zsh/fish (completion-location)
add_completions "new-Cobra"
