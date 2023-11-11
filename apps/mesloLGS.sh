#!/bin/sh

program_long_name="MesloLGS-NF"
program_name="mesloLGS"
repo="ryanoasis/nerd-fonts"
program_type="font"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match for all architectures
download_all_arch='Meslo\.tar\.xz'

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "MesloLGSNerdFont-*.ttf"

#Uninstall old program version
uninstall_old_version
