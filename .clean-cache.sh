#!/bin/sh

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Set the root of the cache directory to clean
    cache_dir="/var/cache/gh-install"
    [ ! -d "$cache_dir" ] && sudo mkdir -p "$cache_dir"

    #Clean cache directories of current package
    find "$cache_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Set cache directory for downloaded files
    cache_dir="/var/cache/gh-install/${package_name}-${online_tag}"
    [ ! -d "$cache_dir" ] && sudo mkdir -p "$cache_dir"

    #Clean cache from old download files
    find "$(dirname "$cache_dir")" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -path "$cache_dir" -exec sudo rm -rf '{}' \;
fi
