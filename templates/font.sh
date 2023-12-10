#!/bin/sh

package_name="name"
repo="owner/repo-name"
package_type="font"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match for all architectures
download_all_arch=''

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "font-name"

#Uninstall old package version
uninstall_old_version
