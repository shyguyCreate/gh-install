#!/bin/sh

program_long_name="Shellcheck"
program_name="shellcheck"
repo="koalaman/shellcheck"
program_type="bin"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match by architecture
download_x64='shellcheck-.*linux\.x86_64\.tar\.xz'
download_arm32='shellcheck-.*linux\.armv6hf\.tar\.xz'
download_arm64='shellcheck-.*linux\.aarch64\.tar\.xz'
download_x32=''

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir "--strip-components=1"

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_name"

#Uninstall old package version
uninstall_old_version
