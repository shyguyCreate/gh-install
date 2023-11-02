#!/bin/sh

program_name="Shfmt"
program_file="shfmt"
repo="mvdan/sh"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'shfmt_.*_linux_amd64'

#Copy download file to install directory
copy_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version
