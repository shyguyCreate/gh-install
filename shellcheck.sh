#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
installDir="/opt"

download_match='shellcheck.*linux\.x86_64\.tar\.xz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

bin_program="$installDir/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
downlaod_program
extract_tar_xz "--strip-components=1"
change_bin_permissions
install_program
uninstall_old_version
