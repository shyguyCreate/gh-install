#!/bin/sh

package_name="shellcheck"
repo="koalaman/shellcheck"
package_type="bin"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match by architecture
download_x64='shellcheck-.*linux\.x86_64\.tar\.xz'
download_arm32='shellcheck-.*linux\.armv6hf\.tar\.xz'
download_arm64='shellcheck-.*linux\.aarch64\.tar\.xz'
download_x32=''

#Download release file
. "$repoDir/.download.sh"

#Uninstall old package version
. "$repoDir/.uninstall.sh"

#Remove num of leading folders in tar archive
strip_components=1
#Remove num of leading folders in tar archive
bin_package="./$package_name"

#Source file with functions
. "$repoDir/.install.sh"
