#!/bin/sh

strip_components=${strip_components:-0}

#Expand tar file to folder installation
case $download_file in
    *.tar.gz) eval "sudo tar zxf $download_file -C $installDir --strip-components=$strip_components" ;;
    *.tar.xz) eval "sudo tar Jxf $download_file -C $installDir --strip-components=$strip_components" ;;
    *) sudo cp "$download_file" "$installDir/$package_name" ;;
esac

bin_directory="/usr/local/bin"
[ ! -d "$bin_directory" ] && sudo mkdir -p "$bin_directory"

case "$package_type" in
    "app")
        #Create symbolic link to bin folder
        sudo ln -sf "$installDir/$bin_package" "$bin_directory/$package_name"
        ;;
    "bin")
        #Copy binary to bin folder and clean tmp folder
        sudo cp "$installDir/$package_name" "$bin_directory/$package_name"
        rm -rf "$installDir"
        ;;
    "font")
        #Specify which fonts should be kept in the system
        find "$installDir" -maxdepth 1 -mindepth 1 -type f -not -name "$font_name" -exec sudo rm -rf '{}' \;
        ;;
esac

#Save package version
touch "$libDir/${package_name}-${online_tag}"

#### Section 3 ####

add_completions()
{
    bash_completion_dir="/usr/local/share/bash-completion/completions"
    zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

    #Create completion directory if not exists
    [ ! -d "$bash_completion_dir" ] && sudo mkdir -p "$bash_completion_dir"
    [ ! -d "$zsh_completion_dir" ] && sudo mkdir -p "$zsh_completion_dir"
    [ ! -d "$fish_completion_dir" ] && sudo mkdir -p "$fish_completion_dir"

    add_completion_file()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Error: Completion file not specified" && exit 1

        #Add completion file to directory based on shell passed
        completion_file="$1"
        completion_dir="$2"
        sudo cp "$completion_file" "$completion_dir"
    }

    add_old_Cobra_completion()
    {
        #Add completions for bash/zsh/fish
        eval "$package_name completion -s bash | sudo tee $bash_completion_dir/$package_name > /dev/null"
        eval "$package_name completion -s zsh | sudo tee $zsh_completion_dir/_$package_name > /dev/null"
        eval "$package_name completion -s fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"
    }

    add_new_Cobra_completion()
    {
        #Add completions for bash/zsh/fish
        eval "$package_name completion bash | sudo tee $bash_completion_dir/$package_name > /dev/null"
        eval "$package_name completion zsh | sudo tee $zsh_completion_dir/_$package_name > /dev/null"
        eval "$package_name completion fish | sudo tee $fish_completion_dir/${package_name}.fish > /dev/null"
    }

    #Exit if no argument was passed
    [ -z "$1" ] && echo "Error: Completion shell not specified" && exit 1

    #Choose which function to pick
    case "$1" in
        "bash") add_completion_file "$2" "$bash_completion_dir" ;;
        "zsh")  add_completion_file "$2" "$zsh_completion_dir"  ;;
        "fish") add_completion_file "$2" "$fish_completion_dir" ;;
        "old-Cobra") add_old_Cobra_completion ;;
        "new-Cobra") add_new_Cobra_completion ;;
    esac
}

#### Section 4 ####

add_image_file()
{
    #Set image directory
    image_dir="/usr/local/share/pixmaps"
    #Save name with extension from image parameter
    image_name="${package_name}.${2##*.}"

    #Check if pixmaps image file exist
    if [ -f "$image_dir/$image_name" ] && [ "$forceFlag" = false ]; then
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
    if [ -f "$desktop_file" ] && [ "$forceFlag" = false ]; then
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
