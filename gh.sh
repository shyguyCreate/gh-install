#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'gh_.*_linux_amd64\.tar\.gz'

#Extract download archive (options to the right)
extract_download "--strip-components=1"

#Copy download file to install directory
copy_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "$installDir/bin/$program_file"

#Uninstall old program version
uninstall_old_version

add_old_Cobra_completions
