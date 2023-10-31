#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'VSCodium-linux-x64-.*\.tar\.gz'
extract_tar_gz
copy_to_install_dir
install_bin "$installDir/bin/$program_file"
uninstall_old_version
add_bash_completion "$installDir/resources/completions/bash/$program_file"
add_zsh_completion "$installDir/resources/completions/zsh/_$program_file"
add_local_image "$installDir/resources/app/resources/linux/code.png"
add_desktop_file false
