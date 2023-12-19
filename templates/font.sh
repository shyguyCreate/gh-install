#!/bin/sh

package_name="name"
repo="owner/repo-name"
package_type="font"

#Save path to root of the repo
installer_dir="$(dirname "$(dirname "$0")")"

#Regex match for all architectures
download_all_arch=''

#Specify that file has checksums with same filename
# hash_extension=''
#Specify filename with checksums
# hash_file=''
#Specify hash algorithm when not found in extension
# hash_algorithm=''

#Remove num of leading folders in tar archive
strip_components=0

#Specify font to keep (wildcards allowed)
font_name="font-name"

#Source file with functions
. "$installer_dir/.install.sh"
