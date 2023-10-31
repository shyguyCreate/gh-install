#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'gh_.*_linux_amd64\.tar\.gz'
extract_tar_gz "--strip-components=1"
copy_to_install_dir
install_bin "$installDir/bin/$program_file"
uninstall_old_version
add_old_Cobra_completions
