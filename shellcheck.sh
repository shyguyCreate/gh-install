#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
program_type="bin"

program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'shellcheck.*linux\.x86_64\.tar\.xz'
extract_tar_xz "--strip-components=1"
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
