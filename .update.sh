#!/bin/sh

#Checks to prevent failure
[ -z "$package_name" ] && echo "Error: package name not specified" && exit 1
[ -z "$package_repo" ] && echo "Error: github repo not specified" && exit 1
[ -z "$refresh_flag" ] || [ -z "$update_command" ] && echo "Error: script run independently" && exit 1

#File to save the tag_name
api_response="/tmp/${package_name}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refresh_flag" = true ]; then
    curl -s "https://api.github.com/repos/$package_repo/releases/latest" -o "$api_response"
fi

#Save tag_name to variable
online_tag="$(grep tag_name "$api_response" | cut -d \" -f 4)"

#Return if command is not run as update
if [ "$update_command" = false ]; then
    return
fi

#Checks to prevent failure
[ -z "$lib_dir" ] || [ -z "$no_install_flag" ] && echo "Error: script run independently" && exit 1

#Get the current version of the package
local_tag="$(find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -printf '%f' -quit | sed "s,${package_name}-,,g")"

#Do nothing if online and local are the same
if [ "$online_tag" = "$local_tag" ]; then
    echo "$package_name is up to date"
    exit
fi

echo "Update found for"
echo "  $package_name  $local_tag => $online_tag"

#Do not install if flag passed
[ "$no_install_flag" = true ] && exit
