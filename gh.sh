#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
installDir="/opt"

program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

bin_program="$installDir/bin/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'gh_.*_linux_amd64\.tar\.gz'
extract_tar_gz "--strip-components=1"
change_bin_permissions
install_program
add_old_Cobra_completions
uninstall_old_version
