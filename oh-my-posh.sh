#!/bin/sh

type="bin"

program_name="Oh-My-Posh"
program_file="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
installDir="/opt"

download_match=''
download_file='posh-linux-amd64'
program_tmp_file="/tmp/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="$installDir/$program_file"

#Install and uninstall
copy_program
change_program_permission
install_program
add_new_Cobra_completions
uninstall_old_version
