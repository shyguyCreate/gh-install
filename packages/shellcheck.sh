#!/bin/sh

#Name to identify package
package_name="shellcheck"

#Specify github repo like this 'owner/repo-name'
package_repo="koalaman/shellcheck"

#Specify type of package (app|bin|font)
package_type="bin"

#Regex match for package for specific architecture
download_x64='shellcheck-.*linux\.x86_64\.tar\.xz'
download_arm32='shellcheck-.*linux\.armv6hf\.tar\.xz'
download_arm64='shellcheck-.*linux\.aarch64\.tar\.xz'
download_x32=''

#Remove num of leading folders in tar archive
strip_components=1

#Path to binary based on download (start with ./)
bin_package="./$package_name"
