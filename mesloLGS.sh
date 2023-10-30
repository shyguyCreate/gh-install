#!/bin/sh

type="font"

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
installDir="/usr/local/share/fonts"

download_match=''
download_file='Meslo.tar.xz'
program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
mkdir -p "/tmp/$program_file"
extract_tar_xz ""
install_font "/tmp/$program_file" "MesloLGSNerdFont-*.ttf"
uninstall_old_version
