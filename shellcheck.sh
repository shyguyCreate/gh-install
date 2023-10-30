#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
installDir="/opt"

download_match='shellcheck.*linux\.x86_64\.tar\.xz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

program_binary="$installDir/$program_file"

#Install and uninstall
extract_program "Jxf $program_tmp_file -C $installDir --strip-components=1"
change_program_permission
install_program
uninstall_old_version
