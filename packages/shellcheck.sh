#!/bin/sh

package_name="shellcheck"
repo="koalaman/shellcheck"
package_type="bin"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match by architecture
download_x64='shellcheck-.*linux\.x86_64\.tar\.xz'
download_arm32='shellcheck-.*linux\.armv6hf\.tar\.xz'
download_arm64='shellcheck-.*linux\.aarch64\.tar\.xz'
download_x32=''

#Remove num of leading folders in tar archive
strip_components=1

#Path to binary based on download (start with ./)
bin_package="./$package_name"

#Source file with functions
. "$installer_dir/.install.sh"
