#!/bin/sh

package_name="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
package_type="bin"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match by architecture
download_x64='posh-linux-amd64'
download_arm32='posh-linux-arm'
download_arm64='posh-linux-arm64'
download_x32='posh-linux-386'

#Specify that file has checksums with same filename
hash_extension='sha256'

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Completions for bash/zsh/fish using Cobra completion command
cobra_completion="new"

#Source file with functions
. "$installer_dir/.install.sh"
