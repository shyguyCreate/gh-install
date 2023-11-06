#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/../.check-install.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Regex match to download release file
download_x64='shellcheck-.*linux\.x86_64\.tar\.xz'
download_arm32='shellcheck-.*linux\.armv6hf\.tar\.xz'
download_arm64='shellcheck-.*linux\.aarch64\.tar\.xz'
download_x32=''

#BIN: Set above matches for each architecture
#FONT: Specify regex match to the right
download_program

#Send download contents to install directory (optional flags)
send_to_install_dir "--strip-components=1"

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version
