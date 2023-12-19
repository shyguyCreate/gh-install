#!/bin/sh

package_name="mesloLGS"
repo="ryanoasis/nerd-fonts"
package_type="font"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match for all architectures
download_all_arch='Meslo\.tar\.xz'

#Specify font to keep (wildcards allowed)
font_name="MesloLGSNerdFont-*.ttf"

#Source file with functions
. "$installer_dir/.install.sh"
