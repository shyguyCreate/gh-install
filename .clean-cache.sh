#!/bin/sh

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Set the root of the cache directory to clean
    cacheDir="/var/cache/gh-install"
    [ ! -d "$cacheDir" ] && sudo mkdir -p "$cacheDir"

    #Clean cache directories of current package
    find "$cacheDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Set cache directory for downloaded files
    cacheDir="/var/cache/gh-install/${package_name}-${online_tag}"
    [ ! -d "$cacheDir" ] && sudo mkdir -p "$cacheDir"

    #Clean cache from old download files
    find "$(dirname "$cacheDir")" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -path "$cacheDir" -exec sudo rm -rf '{}' \;
fi
