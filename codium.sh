#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"

#Source file with functions
. "$(dirname "$0")/.install.sh"

download_match='VSCodium-linux-x64-.*\.tar\.gz'
program_tmp_file="/tmp/$program_file.tar.gz"

#Check if program is already downloaded
if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
    downlaod_program
fi

completion_bash="$installDir/resources/completions/bash/$program_file"
completion_zsh="$installDir/resources/completions/zsh/_$program_file"
program_image="$installDir/resources/app/resources/linux/code.png"

#Start program installation
extract_program ""
install_program
add_bash_completion
add_zsh_completion
add_image
uninstall_old_version

program_desktop_file="/usr/local/share/applications/$program_file.desktop"
desktop_file_content=$(
    cat << EOF
[Desktop Entry]
Name=VSCodium
Comment=Free/Libre Open Source Software Binaries of VS Code
GenericName=VSCodium
Exec=/usr/local/bin/codium
Icon=/usr/local/share/pixmaps/code.png
Categories=Utility;TextEditor;Development;IDE
Type=Application
EOF
)

#Check if .desktop file exist
if [ ! -f "$program_desktop_file" ] || [ $forceFlag = true ]; then
    set_desktop_file
fi
