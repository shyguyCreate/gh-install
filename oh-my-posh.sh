#!/bin/sh

program_name="Oh-My-Posh"
program_file="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Specify regex match to the right
download_program 'posh-linux-amd64'

#Install and uninstall
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
add_new_Cobra_completions
