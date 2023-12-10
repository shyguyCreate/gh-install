#!/bin/sh

package_name="shfmt"
repo="mvdan/sh"
package_type="bin"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match by architecture
download_x64='shfmt_.*_linux_amd64'
download_arm32='shfmt_.*_linux_arm'
download_arm64='shfmt_.*_linux_arm64'
download_x32='shfmt_.*_linux_386'

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_package "$installDir/$package_name"

#Uninstall old package version
uninstall_old_version
