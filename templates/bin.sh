#!/bin/sh

program_long_name="Name"
program_name="name"
repo="owner/repo-name"
program_type="bin"

#Check if should install
. "$(dirname "$0")/../.check-install.sh"

#Regex match by architecture
download_x64=''
download_arm32=''
download_arm64=''
download_x32=''

#Specify that file has checksums with same filename
hash_extension=''
#Specify filename with checksums
hash_file=''
#Specify hash algorithm when not found in extension
hash_algorithm=''

#Download release file
. "$(dirname "$0")/../.download.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the package binary location
#FONT: Specify which fonts should be kept
install_program "install-directory/binary"

#Uninstall old package version
uninstall_old_version

#Add completion file for bash/zsh/fish (completion-location)
# add_completions "bash" "location-of-completion-file-for-bash"
# add_completions "zsh" "location-of-completion-file-for-zsh"
# add_completions "fish" "location-of-completion-file-for-fish"
# add_completions "old-Cobra"
# add_completions "new-Cobra"

#Add image file to system (local|onine) (image-location|url)
# add_image_file "local" "image-location"
# add_image_file "online" "url"

#Add desktop file to system (true|false for terminal application)
# add_desktop_file false
