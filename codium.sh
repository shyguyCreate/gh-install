#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"

download_match='VSCodium-linux-x64-.*\.tar\.gz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

program_binary="$installDir/bin/$program_file"

#Start program installation
extract_program "zxf" ""
change_program_permission
install_program
add_bash_completion "$installDir/resources/completions/bash/$program_file"
add_zsh_completion "$installDir/resources/completions/zsh/_$program_file"
add_image "$installDir/resources/app/resources/linux/code.png"
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
    add_desktop_file
fi
