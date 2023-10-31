#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
installDir="/usr/local/share/fonts"

program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_literal 'Meslo.tar.xz'
mkdir -p "/tmp/$program_file"
extract_tar_xz ""
install_font "/tmp/$program_file" "MesloLGSNerdFont-*.ttf"
uninstall_old_version
