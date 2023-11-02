#!/bin/sh

program_name="Oh-My-Posh"
program_file="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/../.check-install.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'posh-linux-amd64'

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version

#Add completion file for bash/zsh/fish
add_completions "new-Cobra"
