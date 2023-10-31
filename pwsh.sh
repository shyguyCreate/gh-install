#!/bin/sh

program_name="Powershell"
program_file="pwsh"
repo="PowerShell/PowerShell"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Install and uninstall
download_from_match 'powershell-.*-linux-x64\.tar\.gz'
extract_tar_gz ""
copy_to_install_dir
install_bin "$installDir/$program_file"
uninstall_old_version
add_new_Cobra_completions
add_internet_image "https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png"
add_desktop_file true
