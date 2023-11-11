#!/bin/sh

program_long_name="Oh-My-Posh"
program_name="oh-my-posh"
repo="JanDeDobbeleer/oh-my-posh"
program_type="bin"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match by architecture
download_x64='posh-linux-amd64'
download_arm32='posh-linux-arm'
download_arm64='posh-linux-arm64'
download_x32='posh-linux-386'

#Specify that file has checksums with same filename
hash_extension='sha256'

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_name"

#Uninstall old program version
uninstall_old_version

#Add completion file for bash/zsh/fish (completion-location)
add_completions "new-Cobra"
