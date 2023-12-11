#!/bin/sh

package_name="mesloLGS"
repo="ryanoasis/nerd-fonts"
package_type="font"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match for all architectures
download_all_arch='Meslo\.tar\.xz'

#Download release file
. "$repoDir/.download.sh"

#Source file with functions
. "$repoDir/.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "MesloLGSNerdFont-*.ttf"

#Uninstall old package version
uninstall_old_version
