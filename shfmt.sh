#!/bin/sh

program_name="Shfmt"
program_file="shfmt"
repo="mvdan/sh"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'shfmt_.*_linux_amd64'
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
