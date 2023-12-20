#!/bin/sh

#Set install dir to empty
install_dir=""

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
lib_dir="/var/lib/gh-install"
find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -exec sudo rm -rf '{}' \;

#Remove completion file for each shell
if [ -n "$bash_completion" ] || [ -n "$zsh_completion" ] || [ -n "$fish_completion" ] || [ -n "$cobra_completion" ]; then

    #Directory of each shell completion
    bash_completion_dir="/usr/local/share/bash-completion/completions"
    zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

    #Remove completion file based on the directory passed
    [ -n "$bash_completion" ] && sudo rm -f "$bash_completion_dir/$(basename "$bash_completion")"
    [ -n "$zsh_completion" ] && sudo rm -f "$zsh_completion_dir/$(basename "$zsh_completion")"
    [ -n "$fish_completion" ] && sudo rm -f "$fish_completion_dir/$(basename "$fish_completion")"

    #Remove bash/zsh/fish completion
    if [ "$cobra_completion" = "old" ] || [ "$cobra_completion" = "new" ]; then
        sudo rm -f "$bash_completion_dir/${package_name}"
        sudo rm -f "$zsh_completion_dir/_${package_name}"
        sudo rm -f "$fish_completion_dir/${package_name}.fish"
    fi

    #Unset completion variables
    unset bash_completion zsh_completion fish_completion cobra_completion
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

    #Unset application image variables
    unset local_desktop_image online_desktop_image
fi
