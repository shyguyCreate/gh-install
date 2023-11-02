#!/bin/sh

program_name="Name"
program_file="name"
repo="owner/repo-name"
program_type="bin"

#Source file with functions
. "$(dirname "$0")/.check-install.sh"

#Source file with functions
. "$(dirname "$0")/.install.sh"

#Download release file based on match to the right (regex enabled)
download_program 'release-filename'

#Send downloaded file or archive contents to install directory (options to the right)
send_to_install_dir

#Link binary to bin folder (specify binary location)
install_bin "install-directory/binary"

#Uninstall old program version
uninstall_old_version

#Add completion file for bash/zsh/fish
# add_completions "bash" "location-of-completion-file-for-bash"
# add_completions "zsh" "location-of-completion-file-for-zsh"
# add_completions "fish" "location-of-completion-file-for-fish"
# add_completions "old-Cobra"
# add_completions "new-Cobra"

#Add image file to system (local/onine) (image-location/url)
# add_image_file "local" "image-location"
# add_image_file "online" "url"

#Add image file to system (true/false for terminal application)
# add_desktop_file
