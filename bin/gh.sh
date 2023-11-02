#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/../.check-install.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'gh_.*_linux_amd64\.tar\.gz'

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir "--strip-components=1"

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/bin/$program_file"

#Uninstall old program version
uninstall_old_version

#Add completion file for bash/zsh/fish
add_completions "old-Cobra"
