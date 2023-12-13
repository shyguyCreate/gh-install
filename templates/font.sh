#!/bin/sh

package_name="name"
repo="owner/repo-name"
package_type="font"

#Save path to root of the repo
repoDir="$(dirname "$(dirname "$0")")"

#Check if should install
. "$repoDir/.check-install.sh"

#Regex match for all architectures
download_all_arch=''

#Download release file
. "$repoDir/.download.sh"

#Uninstall old package version
. "$repoDir/.uninstall.sh"

font_name="font-name"

#Source file with functions
. "$repoDir/.install.sh"
