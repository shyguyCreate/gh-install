#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'VSCodium-linux-x64-.*\.tar\.gz'

#Extract download archive (options to the right)
extract_download

#Copy download file to install directory
copy_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "$installDir/bin/$program_file"

#Uninstall old program version
uninstall_old_version

add_bash_completion "$installDir/resources/completions/bash/$program_file"
add_zsh_completion "$installDir/resources/completions/zsh/_$program_file"
add_local_image "$installDir/resources/app/resources/linux/code.png"
add_desktop_file false
