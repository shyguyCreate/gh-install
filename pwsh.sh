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

#Extract download archive (options to the right)
extract_download

#Copy download file to install directory
copy_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "$installDir/$program_file"

#Uninstall old program version
uninstall_old_version

add_new_Cobra_completions
add_internet_image "https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"
add_desktop_file true
