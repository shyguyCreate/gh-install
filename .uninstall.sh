#!/bin/sh

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Remove all package contents if already installed
    sudo rm -rf  "$installDir"
    find "$libDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Remove all package contents except the one just installed
    sudo rm -rf  "$installDir"
    find "$libDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;
fi
