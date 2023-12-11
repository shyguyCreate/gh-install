#!/bin/sh

package_name="gh"
repo="cli/cli"
package_type="bin"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

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
. "$repoDir/.download.sh"

#Source file with functions
. "$repoDir/.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir "--strip-components=1"

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "$installDir/bin/$package_name"

#Uninstall old package version
uninstall_old_version

#Add completion file for bash/zsh/fish (completion-location)
add_completions "old-Cobra"
