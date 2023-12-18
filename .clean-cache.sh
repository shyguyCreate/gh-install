#!/bin/sh

#Set the root of the cache directory to clean
cache_dir="/var/cache/gh-install"
[ ! -d "$cache_dir" ] && sudo mkdir -p "$cache_dir"

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Clean cache directories of current package
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;
else
    #Clean cache from old download files
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;
fi
