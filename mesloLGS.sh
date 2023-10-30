#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
installDir="/usr/local/share/fonts"

download_match=''
download_file='Meslo.tar.xz'
program_tmp_file="/tmp/$program_file.tar.xz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

save_latest_tag
get_latest_tag
set_install_dir
get_current_version

should_install

#Source file with functions
. "$(dirname "$0")/.font.sh"

#Install and uninstall
downlaod_program
mkdir -p "/tmp/$program_file"
extract_tar_xz ""
install_font "/tmp/$program_file" "MesloLGSNerdFont-*.ttf"
uninstall_old_version
