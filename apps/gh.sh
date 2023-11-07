#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"
program_type="bin"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match by architecture
download_x64='gh_.*_linux_amd64\.tar\.gz'
download_arm32='gh_.*_linux_armv6\.tar\.gz'
download_arm64='gh_.*_linux_arm64\.tar\.gz'
download_x32='gh_.*_linux_386\.tar\.gz'

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir "--strip-components=1"

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/bin/$program_file"

#Uninstall old program version
uninstall_old_version

#Add completion file for bash/zsh/fish (completion-location)
add_completions "old-Cobra"
