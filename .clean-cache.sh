#!/bin/sh

#Set the root of the cache directory to clean
cache_dir="/var/cache/gh-installer"
[ ! -d "$cache_dir" ] && sudo mkdir -p "$cache_dir"

#If package name is still not set
if [ -z "$package_name" ]; then

    #Clean all cache directories
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -exec sudo rm -rf '{}' \;
    return
fi

#Continue if package name is set

#If online tag is still not set
if [ -z "$online_tag" ]; then

    #Clean cache directories of current package
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;
else
    #Clean cache from old download files
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;
fi
