#!/bin/sh

program_name="Name"
program_file="name"
repo="owner/repo-name"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/../.check-install.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Download release file (specifiy match [regex])
download_program 'release-filename'

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "install-directory/binary"

#Uninstall old program version
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
