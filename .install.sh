#!/bin/sh

#Checks to prevent failure
[ -z "$installer_dir" ] && echo "Error: script run independently" && exit 1

#Download release file
. "$installer_dir/.download.sh"

#Checks to prevent failure
[ -z "$package_name" ] && echo "Error: package name not specified" && exit 1
[ -z "$package_type" ] && echo "Error: package type not specified" && exit 1
[ -z "$lib_dir" ] && echo "Error: script run independently" && exit 1

#Set the root of the install directory based on type of package
case "$package_type" in
    "app") install_dir="/opt/${package_name}" ;;
    "font") install_dir="/usr/local/share/fonts/${package_name}" ;;
esac

#Create tmp folder for package extraction
package_dir="/tmp/$package_name"
sudo mkdir -p "$package_dir"

#Set strip-components to cero if not set
strip_components=${strip_components:-0}

#Expand tar file to folder installation
case $download_file in
    *.tar.gz) eval "sudo tar zxf $download_file -C $package_dir --strip-components=$strip_components" ;;
    *.tar.xz) eval "sudo tar Jxf $download_file -C $package_dir --strip-components=$strip_components" ;;
    *) sudo cp "$download_file" "$package_dir/$package_name" ;;
esac

#Install package based on type
case "$package_type" in
    "app" | "bin")
        #Check if bin file exists
        [ ! -f "$package_dir/${bin_package#./}" ] && echo "Error: Binary not found" && exit 1
        #Set bin directory and create it
        bin_directory="/usr/local/bin"
        [ ! -d "$bin_directory" ] && sudo mkdir -p "$bin_directory"
        #Make binary executable
        sudo chmod +x "$package_dir/${bin_package#./}"
        ;;
esac
case "$package_type" in
    "app")
        #Remove old version
        [ -d "$install_dir" ] && sudo rm -rf "$install_dir"
        #Move tmp folder to install directory
        sudo mv -f "$package_dir" "$install_dir"
        #Create symbolic link to bin folder
        sudo ln -sf "$install_dir/${bin_package#./}" "$bin_directory/$package_name"
        #Set package directory as install since directory was moved
        package_dir="$install_dir"
        ;;
    "bin")
        #Copy binary to bin folder
        sudo mv -f "$package_dir/${bin_package#./}" "$bin_directory/$package_name"
        ;;
    "font")
        #Check if fonts exists
        [ "$(find "$package_dir" -maxdepth 1 -mindepth 1 -name "$font_name" | wc -l)" = 0 ] && echo "Error: Fonts not found" && exit 1
        #Remove old version
        [ -d "$install_dir" ] && sudo rm -rf "$install_dir"
        #Make directory for install
        sudo mkdir -p "$install_dir"
        #Specify which fonts should be kept in the system
        find "$package_dir" -maxdepth 1 -mindepth 1 -name "$font_name" -exec sudo mv -f '{}' "$install_dir" \;
        ;;
esac

#Remove package version from lib except the one just set
find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -name "${package_name}-*" -not -name "${package_name}-${online_tag}" -exec sudo rm -rf '{}' \;

#Save package version
sudo touch "$lib_dir/${package_name}-${online_tag}"

#Add completion file for each shell
if [ -n "$bash_completion" ] || [ -n "$zsh_completion" ] || [ -n "$fish_completion" ] || [ -n "$cobra_completion" ]; then

    #Directory of each shell completion
    bash_completion_dir="/usr/local/share/bash-completion/completions"
    zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

    #Create completion directory if not exists
    [ ! -d "$bash_completion_dir" ] && sudo mkdir -p "$bash_completion_dir"
    [ ! -d "$zsh_completion_dir" ] && sudo mkdir -p "$zsh_completion_dir"
    [ ! -d "$fish_completion_dir" ] && sudo mkdir -p "$fish_completion_dir"

    #Add completion file based on the directory passed
    [ -n "$bash_completion" ] && [ -f "$package_dir/${bash_completion#./}" ] && sudo cp "$package_dir/${bash_completion#./}" "$bash_completion_dir"
    [ -n "$zsh_completion" ]  && [ -f "$package_dir/${zsh_completion#./}" ] && sudo cp "$package_dir/${zsh_completion#./}" "$zsh_completion_dir"
    [ -n "$fish_completion" ] && [ -f "$package_dir/${fish_completion#./}" ] && sudo cp "$package_dir/${fish_completion#./}" "$fish_completion_dir"

    #Choose one Cobra completion command
    if [ "$cobra_completion" = "old" ]; then
        #Execute completion command and passed it to bash/zsh/fish completion directory
        eval "$bin_directory/$package_name completion -s bash | sudo tee $bash_completion_dir/${package_name} > /dev/null"
        eval "$bin_directory/$package_name completion -s zsh | sudo tee $zsh_completion_dir/_${package_name} > /dev/null"
        eval "$bin_directory/$package_name completion -s fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"

    elif [ "$cobra_completion" = "new" ]; then
        #Execute completion command and passed it to bash/zsh/fish completion directory
        eval "$bin_directory/$package_name completion bash | sudo tee $bash_completion_dir/${package_name} > /dev/null"
        eval "$bin_directory/$package_name completion zsh | sudo tee $zsh_completion_dir/_${package_name} > /dev/null"
        eval "$bin_directory/$package_name completion fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"
    fi
fi

#Add application image and .desktop files for current package
if [ "$install_command" = true ] && [ -n "$local_desktop_image" ] || [ -n "$online_desktop_image" ]; then

    #Set directory for applications image
    image_dir="/usr/local/share/pixmaps"
    #Create directory for applications image
    [ ! -d "$image_dir" ] && sudo mkdir -p "$image_dir"

    #Set image name with extension from the image specified
    [ -n "$local_desktop_image" ]  && image_file="$image_dir/${package_name}.${local_desktop_image##*.}"
    [ -n "$online_desktop_image" ] && image_file="$image_dir/${package_name}.${online_desktop_image##*.}"

    #Check if package image file exist
    if [ ! -f "$image_file" ]; then
        [ -n "$local_desktop_image" ]  && sudo cp "$package_dir/${local_desktop_image#./}" "$image_file"
        [ -n "$online_desktop_image" ] && sudo curl -s "$online_desktop_image" -o "$image_file"
    fi

    #Set directory for .desktop files
    desktop_dir="/usr/local/share/applications"
    #Create directory for .desktop files
    [ ! -d "$desktop_dir" ] && sudo mkdir -p "$desktop_dir"

    #Set .desktop file name inside applications
    desktop_file="$desktop_dir/${package_name}.desktop"

    #Check if .desktop file exist
    if [ ! -f "$desktop_file" ]; then

        #Set if package should be run on the terminal
        is_terminal="${is_terminal:-false}"

        #Add package .desktop file
        echo \
            "[Desktop Entry]
            Type=Application
            Name=$package_name
            GenericName=$package_name
            Exec=$bin_directory/$package_name
            Icon=$image_file
            Categories=Utility;Development
            Terminal=$is_terminal" \
            | sed 's/^[ \t]*//' - \
            | sudo tee "$desktop_file" > /dev/null
    fi
fi

#Clean tmp folder
sudo rm -rf "/tmp/$package_name"
