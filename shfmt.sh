#!/bin/sh

program_name="Shfmt"
program_file="shfmt"
repo="mvdan/sh"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Specify regex match to the right
download_program 'shfmt_.*_linux_amd64'

#Install and uninstall
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
