#!/bin/sh

#Set the root of the install directory based on type of package
case "$package_type" in
    "app") install_dir="/opt/${package_name}" ;;
    "font") install_dir="/usr/local/share/fonts/${package_name}" ;;
esac

#Remove packages installed
[ -n "$install_dir" ] && sudo rm -rf "$install_dir"

#If online tag  is still not set
if [ -z "${online_tag}" ]; then

    #Remove all package contents if already installed
    find "$lib_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -exec sudo rm -rf '{}' \;

else
    #Remove all package contents except the one just installed
    find "$lib_dir" -maxdepth 1 -mindepth 1 -type d -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;
fi

#Check if type is bin or app
if [ "$package_type" = "bin" ] || [ "$package_type" = "app" ]; then
    #Set directory and create it
    bin_directory="/usr/local/bin"
    [ ! -d "$bin_directory" ] && sudo mkdir -p "$bin_directory"
    #Remove bin packages
    sudo rm -f "$bin_directory/$package_name"

elif [ "$package_type" = "font" ]; then
    #Make parent directory for install
    [ ! -d "$install_dir" ] && sudo mkdir -p "$install_dir"
fi
