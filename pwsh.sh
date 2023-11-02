#!/bin/sh

program_name="Powershell"
program_file="pwsh"
repo="PowerShell/PowerShell"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'powershell-.*-linux-x64\.tar\.gz'

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version

#Add image file to system (local/onine) (image-location/url)
add_image_file "online" "https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"

#Add image file to system (true/false for terminal application)
add_desktop_file true
