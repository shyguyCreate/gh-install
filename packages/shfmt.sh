#!/bin/sh

package_name="shfmt"
repo="mvdan/sh"
package_type="bin"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match by architecture
download_x64='shfmt_.*_linux_amd64'
download_arm32='shfmt_.*_linux_arm'
download_arm64='shfmt_.*_linux_arm64'
download_x32='shfmt_.*_linux_386'

#Download release file
. "$repoDir/.download.sh"

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Source file with functions
. "$repoDir/.install.sh"
