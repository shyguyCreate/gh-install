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

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "$installDir/bin/$program_file"

#Uninstall old program version
uninstall_old_version

add_completion "bash" "$installDir/resources/completions/bash/$program_file"
add_completion "zsh" "$installDir/resources/completions/zsh/_$program_file"
add_image_file "local" "$installDir/resources/app/resources/linux/code.png"
add_desktop_file false
