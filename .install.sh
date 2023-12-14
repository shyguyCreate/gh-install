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
        sudo mv -f "$tmp_dir" "$intall_dir"
        #Make binary executable
        sudo chmod +x "$intall_dir/${bin_package#./}"
        #Create symbolic link to bin folder
        sudo ln -sf "$intall_dir/${bin_package#./}" "$bin_directory/$package_name"
        ;;
    "bin")
        #Copy binary to bin folder
        sudo mv -f "$tmp_dir/${bin_package#./}" "$bin_directory/$package_name"
        #Make binary executable
        sudo chmod +x "$bin_directory/$package_name"
        ;;
    "font")
        #Specify which fonts should be kept in the system
        find "$tmp_dir" -maxdepth 1 -mindepth 1 -name "$font_name" -exec sudo mv -f '{}' "$intall_dir" \;
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
    [ -n "$bash_completion" ] && [ -f "$intall_dir/${bash_completion#./}" ] && sudo cp "$intall_dir/${bash_completion#./}" "$bash_completion_dir"
    [ -n "$zsh_completion" ]  && [ -f "$intall_dir/${zsh_completion#./}" ] && sudo cp "$intall_dir/${zsh_completion#./}" "$zsh_completion_dir"
    [ -n "$fish_completion" ] && [ -f "$intall_dir/${fish_completion#./}" ] && sudo cp "$intall_dir/${fish_completion#./}" "$fish_completion_dir"

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

#### Section 4 ####

add_image_file()
{
    #Set image directory
    image_dir="/usr/local/share/pixmaps"
    #Save name with extension from image parameter
    image_name="${package_name}.${2##*.}"

    #Check if pixmaps image file exist
    if [ -f "$image_dir/$image_name" ] && [ "$force_flag" = false ]; then
        return
    fi

    add_local_image()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Error: Image location not specified" && exit 1
        #Add package image file from computer
        local_image_dir="$1"
        sudo mkdir -p "$image_dir"
        sudo cp "$local_image_dir" "$image_dir/$image_name"
    }

    add_online_image()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Error: Url not specified" && exit 1
        #Add package image file from internet
        url="$1"
        sudo mkdir -p "$image_dir"
        sudo curl -s "$url" -o "$image_dir/$image_name"
    }

    #Exit if no argument was passed
    [ -z "$1" ] && echo "Error: Image type (local|onine) not specified" && exit 1

    #Choose which function to pick
    case "$1" in
        "local") add_local_image "$2" ;;
        "online") add_online_image "$2" ;;
    esac
}

#### Section 5 ####

add_desktop_file()
{
    desktop_file="/usr/local/share/applications/${package_name}.desktop"

    #Check if .desktop file exist
    if [ -f "$desktop_file" ] && [ "$force_flag" = false ]; then
        return
    fi

    #Exit if argument is incorrect
    [ "$1" != true ] && [ "$1" != false ] && echo "Error: Argument only accepts true or false" && exit 1

    #Set if package should be run on the terminal
    is_terminal="${1:-false}"

    #Add package .desktop file
    sudo mkdir -p "$(dirname "$desktop_file")"
    echo \
        "[Desktop Entry]
        Type=Application
        Name=$package_name
        GenericName=$package_name
        Exec=$bin_directory/$package_name
        Icon=$image_dir/$image_name
        Categories=Utility;Development
        Terminal=$is_terminal" \
        | sed 's/^[ \t]*//' - \
        | sudo tee "$desktop_file" > /dev/null
}
