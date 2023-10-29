#!/bin/sh

program_name="VSCodium"
program_file="codium"
repo="VSCodium/vscodium"

download_match='VSCodium-linux-x64-.*\.tar\.gz'
program_tmp_file="/tmp/$program_file.tar.gz"
program_desktop_file="/usr/local/share/applications/$program_file.desktop"

desktop_file_content=$(
    cat << EOF
[Desktop Entry]
Name=VSCodium
Comment=Free/Libre Open Source Software Binaries of VS Code
GenericName=VSCodium
Exec=/usr/local/bin/codium
Icon=/usr/local/share/pixmaps/codium.png
Categories=Utility;TextEditor;Development;IDE
Type=Application
EOF
)

#Source file with functions
. "$(dirname "$0")/.install.sh"
