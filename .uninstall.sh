#!/bin/sh

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Remove all package contents if already installed
    find "$installDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Remove all package contents except the one just installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \;
fi
