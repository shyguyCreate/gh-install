#!/bin/sh

[ -z "$package_name" ] && echo "Error: package name not specified" && exit 1
[ -z "$package_repo" ] && echo "Error: github repo not specified" && exit 1

#Set directory to save package version
lib_dir="/var/lib/gh-installer"
[ ! -d "$lib_dir" ] && sudo mkdir -p "$lib_dir"

#Get the current version of the package
local_tag="$(find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -printf '%f' -quit | sed "s,${package_name}-,,g")"

#File to save the tag_name
api_response="/tmp/${package_name}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refresh_flag" = true ]; then
    curl -s "https://api.github.com/repos/$package_repo/releases/latest" -o "$api_response"
fi

#Save tag_name to variable
online_tag="$(grep tag_name "$api_response" | cut -d \" -f 4)"

if [ "$online_tag" != "$local_tag" ]; then
    echo "  $package_name  $local_tag => $online_tag"
fi
