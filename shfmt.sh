#!/bin/sh

type="bin"

program_name="Shfmt"
program_file="shfmt"
repo="mvdan/sh"
installDir="/opt"

download_match='shfmt_.*_linux_amd64'
download_file=''
program_tmp_file="/tmp/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="$installDir/$program_file"

#Install and uninstall
copy_program
change_program_permission
install_program
uninstall_old_version
