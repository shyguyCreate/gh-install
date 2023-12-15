#!/bin/sh

package_name="name"
repo="owner/repo-name"
package_type="bin"

#Save path to root of the repo
repo_dir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repo_dir/.check-install.sh"

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
. "$repo_dir/.download.sh"

#Remove num of leading folders in tar archive
strip_components=0
#Path to binary based on download (start with ./)
bin_package="./path/to/bin"

#Path to completion file based on download (start with ./)
# bash_completion="./location-of-completion-file-for-bash"
# zsh_completion="./location-of-completion-file-for-zsh"
# fish_completion="./location-of-completion-file-for-fish"

#Completions for bash/zsh/fish using Cobra completion command
# cobra_completion="old"
# cobra_completion="new"

#Path to image file based on download (start with ./)
# local_image="./location-of-image-file"

#Url for application image
# online_image="url"

#Add desktop file to system
# need_desktop_file=true
# is_terminal=false

#Source file with functions
. "$repo_dir/.install.sh"
