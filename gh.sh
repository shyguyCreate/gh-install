#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
installDir="/opt"

download_match='gh_.*_linux_amd64\.tar\.gz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="$installDir/bin/$program_file"

save_latest_tag
get_latest_tag
set_install_dir
get_current_version

should_install

#Source file with functions
. "$(dirname "$0")/.bin.sh"

#Install and uninstall
downlaod_program
extract_tar_gz "--strip-components=1"
change_bin_permissions
install_program
add_old_Cobra_completions
uninstall_old_version
