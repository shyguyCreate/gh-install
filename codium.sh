#!/bin/sh

type="bin"

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"
installDir="/opt"

download_match='VSCodium-linux-x64-.*\.tar\.gz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="$installDir/bin/$program_file"

#Start program installation
extract_tar_gz ""
change_bin_permissions
install_program
add_bash_completion "$installDir/resources/completions/bash/$program_file"
add_zsh_completion "$installDir/resources/completions/zsh/_$program_file"

image_name="$program_name.png"
add_local_image "$installDir/resources/app/resources/linux/code.png"

uninstall_old_version

add_desktop_file false
