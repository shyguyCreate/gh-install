#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
program_type="font"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'Meslo.tar.xz'

#Extract download archive (options to the right)
extract_download

#Copy download file to install directory
copy_to_install_dir

#Copy fonts to font directory (optionally specify font name)
install_font "MesloLGSNerdFont-*.ttf"

#Uninstall old program version
uninstall_old_version
