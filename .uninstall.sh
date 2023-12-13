#!/bin/sh

#Set the root of the install directory based on type of package
case "$package_type" in
    "app") installDir="/opt/${package_name}" ;;
    "bin") installDir="/tmp/${package_name}" ;;
    "font") installDir="/usr/local/share/fonts/${package_name}" ;;
esac

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Remove all package contents if already installed
    sudo rm -rf "$installDir"
    find "$libDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Remove all package contents except the one just installed
    sudo rm -rf "$installDir"
    find "$libDir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;
fi

#Make parent directory for install
[ ! -d "$installDir" ] && sudo mkdir -p "$installDir"
