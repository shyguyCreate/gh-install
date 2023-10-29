#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"

#Source file with functions
. "$(dirname "$0")/.install.sh"

download_match='gh_.*_linux_amd64\.tar\.gz'
program_tmp_file="/tmp/$program_file.tar.gz"

#Check if program is already downloaded
if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
    downlaod_program
fi

#Install and uninstall
extract_program "--strip-components=1"
install_program
add_Cobra_completions
uninstall_old_version
