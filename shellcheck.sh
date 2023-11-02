#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'shellcheck.*linux\.x86_64\.tar\.xz'

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir "--strip-components=1"

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version
