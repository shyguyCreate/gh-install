#!/bin/sh

type="bin"

program_name="Powershell"
program_file="pwsh"
repo="PowerShell/PowerShell"
installDir="/opt"

download_match='powershell-.*-linux-x64\.tar\.gz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="$installDir/$program_file"

#Install and uninstall
extract_gz ""
change_program_permission
install_program
add_new_Cobra_completions
uninstall_old_version

#Check if pixmaps image file exist
if [ ! -f "$program_image_file" ] || [ $forceFlag = true ]; then
    add_internet_image "pwsh.png" "https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"
fi

program_desktop_file="/usr/local/share/applications/$program_file.desktop"
desktop_file_content=$(
    cat << EOF
[Desktop Entry]
Name=Powershell
Comment=Powershell Core
GenericName=Powershell
Exec=/usr/local/bin/pwsh
Icon=/usr/local/share/pixmaps/pwsh.png
Categories=Utility;Development;Shell
Type=Application
Terminal=true
EOF
)

#Check if .desktop file exist
if [ ! -f "$program_desktop_file" ] || [ $forceFlag = true ]; then
    add_desktop_file
fi
