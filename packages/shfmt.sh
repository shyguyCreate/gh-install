#!/bin/sh

package_name="shfmt"
repo="mvdan/sh"
package_type="bin"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match by architecture
download_x64='shfmt_.*_linux_amd64'
download_arm32='shfmt_.*_linux_arm'
download_arm64='shfmt_.*_linux_arm64'
download_x32='shfmt_.*_linux_386'

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Source file with functions
. "$installer_dir/.install.sh"
