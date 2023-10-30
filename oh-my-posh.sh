#!/bin/sh

program_name="Oh-My-Posh"
program_file="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
installDir="/opt"

download_match=''
download_file='posh-linux-amd64'
program_tmp_file="/tmp/$program_file"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

bin_program="$installDir/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
downlaod_program
copy_program
change_bin_permissions
install_program
add_new_Cobra_completions
uninstall_old_version
