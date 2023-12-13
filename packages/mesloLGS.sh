#!/bin/sh

package_name="mesloLGS"
repo="ryanoasis/nerd-fonts"
package_type="font"

#Save path to root of the repo
repo_dir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repo_dir/.check-install.sh"

#Regex match for all architectures
download_all_arch='Meslo\.tar\.xz'

#Download release file
. "$repo_dir/.download.sh"

#Specify font to keep (wildcards allowed)
font_name="MesloLGSNerdFont-*.ttf"

#Source file with functions
. "$repo_dir/.install.sh"
