#!/bin/sh

program_name="Name"
program_file="name"
repo="owner/repo-name"
program_type="font"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'release-filename'

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir

#Copy fonts to font directory (optionally specify font name)
install_font "font-name"

#Uninstall old program version
uninstall_old_version
