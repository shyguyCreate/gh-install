#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
program_type="font"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Specify regex match to the right
download_program 'Meslo.tar.xz'

#Install and uninstall
extract_tar_xz ""
copy_to_install_dir
install_font "MesloLGSNerdFont-*.ttf"
uninstall_old_version
