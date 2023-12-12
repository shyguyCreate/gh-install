#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -d to download only"
    echo "  -f to force installation"
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
cleanFlag=false
downloadFlag=false
forceFlag=false
hashFlag=false
installFlag=false
removeFlag=false
updateFlag=false
refreshFlag=false
while getopts ":cdfiruxy" opt; do
    case $opt in
        c) cleanFlag=true ;;
        d) downloadFlag=true ;;
        f) forceFlag=true ;;
        i) installFlag=true ;;
        r) removeFlag=true ;;
        u) updateFlag=true ;;
        x) hashFlag=true ;;
        y) refreshFlag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Set directory to save package version
libDir="/var/lib/gh-install"
[ ! -d "$libDir" ] && sudo mkdir -p "$libDir"

#Clean cache if -c flag was passed
[ "$cleanFlag" = true ] && . "$repoDir/.clean-cache.sh"

#Set the root of the install directory based on type of package
case "$package_type" in
    "bin") installDir="/opt/${package_name}" ;;
    "font") installDir="/usr/local/share/fonts/${package_name}" ;;
esac

#Make parent directory for install
[ ! -d "$installDir" ] && sudo mkdir -p "$installDir"

#Test if -r flag was passed
[ "$removeFlag" = true ] && . "$repoDir/.uninstall.sh"

#Exit if -c or -r flag was passed
[ "$cleanFlag" = true ] || [ "$removeFlag" = true ] && exit

#Get the current version of the package
local_tag="$(find "$libDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -printf '%f' -quit | sed "s,${package_name}-,,g")"

#File to save the tag_name
api_response="/tmp/${package_name}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" -o "$api_response"
fi

#Save tag_name to variable
online_tag="$(grep tag_name "$api_response" | cut -d \" -f 4)"

#Install if github version is not equal to installed version and -u
#Or if package is not installed or if -dfi flag is passed
if [ "$downloadFlag" = true ]; then
    echo "Begin $package_name download..."

elif [ "$online_tag" != "$local_tag" ] && [ "$updateFlag" = true ] || [ -z "$local_tag" ] || [ "$installFlag" = true ] || [ "$forceFlag" = true ]; then
    echo "Begin $package_name installation..."

elif [ "$updateFlag" = false ] && [ "$online_tag" = "$local_tag" ]; then
    echo "No update found for $package_name"
    exit
elif [ "$updateFlag" = false ] && [ "$online_tag" != "$local_tag" ]; then
    echo "Update found for $package_name"
    exit
else
    echo "$package_name is up to date"
    exit
fi
