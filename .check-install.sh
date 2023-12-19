#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -d to download only"
    echo "  -i to (re)install package"
    echo "  -r to remove package"
    echo "  -u to update package"
    echo "  -x to ignore hashes"
    echo "  -y to refresh github api response"
}

usage()
{
    echo "Flags:"
    usage_flags
    exit
}

#Add flags to script
clean_flag=false
download_flag=false
hash_flag=false
install_flag=false
remove_flag=false
update_flag=false
refresh_flag=false
while getopts ":cdfiruxy" opt; do
    case $opt in
        c) clean_flag=true ;;
        d) download_flag=true ;;
        i) install_flag=true ;;
        r) remove_flag=true ;;
        u) update_flag=true ;;
        x) hash_flag=true ;;
        y) refresh_flag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Clean cache if -c flag was passed
[ "$clean_flag" = true ] && . "$installer_dir/.clean-cache.sh"

#Test if -r flag was passed
[ "$remove_flag" = true ] && . "$installer_dir/.uninstall.sh"

#Exit if -c or -r flag was passed
[ "$clean_flag" = true ] || [ "$remove_flag" = true ] && exit

#Set directory to save package version
lib_dir="/var/lib/gh-install"
[ ! -d "$lib_dir" ] && sudo mkdir -p "$lib_dir"

#Get the current version of the package
local_tag="$(find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -printf '%f' -quit | sed "s,${package_name}-,,g")"

#File to save the tag_name
api_response="/tmp/${package_name}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refresh_flag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" -o "$api_response"
fi

#Save tag_name to variable
online_tag="$(grep tag_name "$api_response" | cut -d \" -f 4)"

#Install if github version is not equal to installed version and -u
#Or if package is not installed or if -dfi flag is passed
if [ "$download_flag" = true ]; then
    echo "Begin $package_name download..."

elif [ "$online_tag" != "$local_tag" ] && [ "$update_flag" = true ] || [ -z "$local_tag" ] || [ "$install_flag" = true ]; then
    echo "Begin $package_name installation..."

elif [ "$update_flag" = false ] && [ "$online_tag" = "$local_tag" ]; then
    echo "No update found for $package_name"
    exit
elif [ "$update_flag" = false ] && [ "$online_tag" != "$local_tag" ]; then
    echo "Update found for $package_name"
    exit
else
    echo "$package_name is up to date"
    exit
fi
