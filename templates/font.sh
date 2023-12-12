#!/bin/sh

package_name="name"
repo="owner/repo-name"
package_type="font"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match for all architectures
download_all_arch=''

#Download release file
. "$repoDir/.download.sh"

#Source file with functions
. "$repoDir/.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "font-name"

#Uninstall old package version
. "$repoDir/.uninstall.sh"
