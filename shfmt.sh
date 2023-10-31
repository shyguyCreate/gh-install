#!/bin/sh

program_name="Shfmt"
program_file="shfmt"
repo="mvdan/sh"
installDir="/opt"

program_tmp_file="/tmp/$program_file"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

bin_program="$installDir/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'shfmt_.*_linux_amd64'
copy_program
change_bin_permissions
install_program
uninstall_old_version
