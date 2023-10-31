#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"
installDir="/opt"

program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

bin_program="$installDir/bin/$program_file"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'VSCodium-linux-x64-.*\.tar\.gz'
extract_tar_gz ""
change_bin_permissions
install_program
add_bash_completion "$installDir/resources/completions/bash/$program_file"
add_zsh_completion "$installDir/resources/completions/zsh/_$program_file"

image_name="$program_file.png"
add_local_image "$installDir/resources/app/resources/linux/code.png"

uninstall_old_version

add_desktop_file false
