#!/bin/sh

program_name="Name"
program_file="name"
repo="owner/repo-name"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'release-filename'

#Extract download archive (options to the right)
extract_download

#Copy download file to install directory
copy_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "install-directory/binary"

#Uninstall old program version
uninstall_old_version
