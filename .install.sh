#!/bin/sh

#Uninstall old package version
. "$repo_dir/.uninstall.sh"

#Create tmp folder for package extraction
tmp_dir="/tmp/$package_name"
sudo mkdir -p "$tmp_dir"

#Set strip-components to cer if not set
strip_components=${strip_components:-0}

#Expand tar file to folder installation
case $download_file in
    *.tar.gz) eval "sudo tar zxf $download_file -C $tmp_dir --strip-components=$strip_components" ;;
    *.tar.xz) eval "sudo tar Jxf $download_file -C $tmp_dir --strip-components=$strip_components" ;;
    *) sudo cp "$download_file" "$tmp_dir/$package_name" ;;
esac

#Install package based on type
case "$package_type" in
    "app")
        #Move tmp folder to install directory
        sudo mv -f "$tmp_dir" "$install_dir"
        #Make binary executable
        sudo chmod +x "$install_dir/${bin_package#./}"
        #Create symbolic link to bin folder
        sudo ln -sf "$install_dir/${bin_package#./}" "$bin_directory/$package_name"
        ;;
    "bin")
        #Copy binary to bin folder
        sudo mv -f "$tmp_dir/${bin_package#./}" "$bin_directory/$package_name"
        #Make binary executable
        sudo chmod +x "$bin_directory/$package_name"
        ;;
    "font")
        #Specify which fonts should be kept in the system
        find "$tmp_dir" -maxdepth 1 -mindepth 1 -name "$font_name" -exec sudo mv -f '{}' "$install_dir" \;
        ;;
esac

#Save package version
sudo touch "$lib_dir/${package_name}-${online_tag}"

#Clean tmp folder
sudo rm -rf "$tmp_dir"

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
    [ -n "$bash_completion" ] && [ -f "$install_dir/${bash_completion#./}" ] && sudo cp "$install_dir/${bash_completion#./}" "$bash_completion_dir"
    [ -n "$zsh_completion" ]  && [ -f "$install_dir/${zsh_completion#./}" ] && sudo cp "$install_dir/${zsh_completion#./}" "$zsh_completion_dir"
    [ -n "$fish_completion" ] && [ -f "$install_dir/${fish_completion#./}" ] && sudo cp "$install_dir/${fish_completion#./}" "$fish_completion_dir"

    #Choose one Cobra completion command
    if [ "$cobra_completion" = "old" ]; then
        #Execute completion command and passed it to bash/zsh/fish completion directory
        eval "$bin_directory/$package_name completion -s bash | sudo tee $bash_completion_dir/$package_name > /dev/null"
        eval "$bin_directory/$package_name completion -s zsh | sudo tee $zsh_completion_dir/_$package_name > /dev/null"
        eval "$bin_directory/$package_name completion -s fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"

    elif [ "$cobra_completion" = "new" ]; then
        #Execute completion command and passed it to bash/zsh/fish completion directory
        eval "$bin_directory/$package_name completion bash | sudo tee $bash_completion_dir/$package_name > /dev/null"
        eval "$bin_directory/$package_name completion zsh | sudo tee $zsh_completion_dir/_$package_name > /dev/null"
        eval "$bin_directory/$package_name completion fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"
    fi
fi

#Add application image file for current package
if [ -n "$local_desktop_image" ] || [ -n "$online_desktop_image" ]; then

    #Set directory for applications image and create it
    image_dir="/usr/local/share/pixmaps"
    [ ! -d "$image_dir" ] && sudo mkdir -p "$image_dir"

    #Set image name with extension from the image specified
    [ -n "$local_desktop_image" ]  && image_file="$image_dir/${package_name}.${local_desktop_image##*.}"
    [ -n "$online_desktop_image" ] && image_file="$image_dir/${package_name}.${online_desktop_image##*.}"

    #Check if package image file exist
    if [ ! -f "$image_file" ]; then
        [ -n "$local_desktop_image" ]  && sudo cp "$install_dir/${local_desktop_image#./}" "$image_file"
        [ -n "$online_desktop_image" ] && sudo curl -s "$online_desktop_image" -o "$image_file"
    fi

    #Set directory for .desktop for current package
    desktop_dir="/usr/local/share/applications"
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
