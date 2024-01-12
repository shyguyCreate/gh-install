#!/bin/sh

#Checks to prevent failure
[ -z "$package_name" ] && echo "Error: package name not specified" && exit 1
[ -z "$package_type" ] && echo "Error: package type not specified" && exit 1
[ -z "$lib_dir" ] && echo "Error: script run independently" && exit 1

#Set the root of the install directory based on type of package
case "$package_type" in
    "app") install_dir="/opt/${package_name}" ;;
    "font") install_dir="/usr/local/share/fonts/${package_name}" ;;
esac

#Remove packages installed
[ -n "$install_dir" ] && sudo rm -rf "$install_dir"

#Check if type is bin or app
if [ "$package_type" = "bin" ] || [ "$package_type" = "app" ]; then
    #Set bin directory and remove bin package
    bin_directory="/usr/local/bin"
    sudo rm -f "$bin_directory/$package_name"
fi

#Remove package version from lib if already set
find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -exec sudo rm -rf '{}' \;

#Remove completion file for each shell
if [ -n "$bash_completion" ] || [ -n "$zsh_completion" ] || [ -n "$fish_completion" ] || [ -n "$cobra_completion" ]; then

    #Directory of each shell completion
    bash_completion_dir="/usr/local/share/bash-completion/completions"
    zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

    #Remove completion file based on the directory passed
    [ -n "$bash_completion" ] && sudo rm -f "$bash_completion_dir/${package_name}"
    [ -n "$zsh_completion" ] && sudo rm -f "$zsh_completion_dir/_${package_name}"
    [ -n "$fish_completion" ] && sudo rm -f "$fish_completion_dir/${package_name}.fish"

    #Remove bash/zsh/fish completion
    if [ "$cobra_completion" = "old" ] || [ "$cobra_completion" = "new" ]; then
        sudo rm -f "$bash_completion_dir/${package_name}"
        sudo rm -f "$zsh_completion_dir/_${package_name}"
        sudo rm -f "$fish_completion_dir/${package_name}.fish"
    fi
fi

#Remove application image file for current package
if [ -n "$local_desktop_image" ] || [ -n "$online_desktop_image" ]; then

    #Set directory for applications image
    image_dir="/usr/local/share/pixmaps"

    #Remove image name with extension from the image specified
    [ -n "$local_desktop_image" ] && sudo rm -f "$image_dir/${package_name}.${local_desktop_image##*.}"
    [ -n "$online_desktop_image" ] && sudo rm -f "$image_dir/${package_name}.${online_desktop_image##*.}"

    #Set directory for .desktop files
    desktop_dir="/usr/local/share/applications"

    #Remove .desktop file name inside applications
    sudo rm -f "$desktop_dir/${package_name}.desktop"
fi
