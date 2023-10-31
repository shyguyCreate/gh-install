#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
program_type="font"

program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_literal 'Meslo.tar.xz'
extract_tar_xz ""
copy_to_install_dir
install_font "MesloLGSNerdFont-*.ttf"
uninstall_old_version
