#!/bin/sh

program_name="Shellcheck"
program_file="shellcheck"
repo="koalaman/shellcheck"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Specify regex match to the right
download_program 'shellcheck.*linux\.x86_64\.tar\.xz'

#Install and uninstall
extract_tar_xz "--strip-components=1"
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
