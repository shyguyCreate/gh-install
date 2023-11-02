#!/bin/sh

#### Section 1 ####

download_program()
{
    #Get the download url by opening the .api.json file and searching with regex
    url=$(grep "\"browser_download_url.*/$1\"" "$api_response" | cut -d \" -f 4)

    #Set path to download file with the name found in the url
    download_file="/tmp/${url##*/}"

    #Start download
    curl -Lf --progress-bar "$url" -o "$download_file"
}

#### Section 2 ####

send_to_install_dir()
{
    #Make directory for install
    sudo mkdir -p "$installDir"

    #Expand tar file to folder installation
    case $download_file in
        *.tar.gz) eval "sudo tar zxf $download_file -C $installDir $1" ;;
        *.tar.xz) eval "sudo tar Jxf $download_file -C $installDir $1" ;;
        *) sudo cp "$download_file" "$installDir/$program_file" ;;
    esac
}

#### Section 3 ####

install_bin()
{
    #Change execute permissions
    bin_program="$1"
    sudo chmod +x "$bin_program"

    #Create symbolic link to bin folder
    bin_directory="/usr/local/bin"
    sudo mkdir -p "$bin_directory"
    sudo ln -sf "$bin_program" "$bin_directory"
}

install_font()
{
    #If no parameter pass, set wildcard to match all files
    font_name="${1:-*}"
    #Copy fonts to install directory
    find "$installDir" -maxdepth 1 -mindepth 1 -type f -name "$font_name" -exec sudo cp '{}' "$installDir" \;
}

#### Section 4 ####

uninstall_old_version()
{
    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+
}

#### Section 5 ####

add_completions()
{
    bash_completion_dir="/usr/local/share/bash-completion/completions"
    zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

    #Create completion directory if not exists
    [ ! -d "$bash_completion_dir" ] && sudo mkdir -p "$bash_completion_dir"
    [ ! -d "$zsh_completion_dir" ] && sudo mkdir -p "$zsh_completion_dir"
    [ ! -d "$fish_completion_dir" ] && sudo mkdir -p "$fish_completion_dir"

    add_bash_completion()
    {
        #Add completions for bash
        completion_file="$1"
        sudo cp "$completion_file" "$bash_completion_dir"
    }

    add_zsh_completion()
    {
        #Add completions for zsh
        completion_file="$1"
        sudo cp "$completion_file" "$zsh_completion_dir"
    }

    add_fish_completion()
    {
        #Add completions for fish
        completion_file="$1"
        sudo cp "$completion_file" "$fish_completion_dir"
    }

    add_old_Cobra_completion()
    {
        #Add completions for bash
        eval "$program_file completion -s bash | sudo tee $bash_completion_dir/$program_file > /dev/null"

        #Add completions for zsh
        eval "$program_file completion -s zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"

        #Add completions for fish
        eval "$program_file completion -s fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
    }

    add_new_Cobra_completion()
    {
        #Add completions for bash
        eval "$program_file completion bash | sudo tee $bash_completion_dir/$program_file > /dev/null"

        #Add completions for zsh
        eval "$program_file completion zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"

        #Add completions for fish
        eval "$program_file completion fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
    }

    #Choose with function to pick
    case "$1" in
        "bash") add_bash_completion "$2" ;;
        "zsh") add_zsh_completion "$2" ;;
        "fish") add_fish_completion "$2" ;;
        "old-Cobra") add_old_Cobra_completion ;;
        "new-Cobra") add_new_Cobra_completion ;;
    esac
}

#### Section 6 ####

add_image_file()
{
    #Set image directory
    image_dir="/usr/local/share/pixmaps"
    #Save name with extension from image parameter
    image_name="${program_file}.${2##*.}"

    #Check if pixmaps image file exist
    if [ -f "$image_dir/$image_name" ] && [ "$forceFlag" = false ]; then
        return
    fi

    add_local_image()
    {
        #Add application image file from computer
        local_image_dir="$1"
        sudo mkdir -p "$image_dir"
        sudo cp "$local_image_dir" "$image_dir/$image_name"
    }

    add_online_image()
    {
        #Add application image file from internet
        url="$1"
        sudo mkdir -p "$image_dir"
        sudo curl -s "$url" -o "$image_dir/$image_name"
    }

    #Choose with function to pick
    case "$1" in
        "local") add_local_image "$2" ;;
        "online") add_online_image "$2" ;;
    esac
}

#### Section 7 ####

add_desktop_file()
{
    desktop_file="/usr/local/share/applications/$program_file.desktop"

    #Check if .desktop file exist
    if [ -f "$desktop_file" ] && [ "$forceFlag" = false ]; then
        return
    fi

    #Set if application should be run on the terminal
    is_terminal="${1:-false}"

    #Add application .desktop file
    sudo mkdir -p "$(dirname "$desktop_file")"
    echo \
        "[Desktop Entry]
        Type=Application
        Name=$program_name
        GenericName=$program_name
        Exec=$bin_directory/$program_file
        Icon=$image_dir/$image_name
        Categories=Utility;Development
        Terminal=$is_terminal" \
        | sed 's/^[ \t]*//' - \
        | sudo tee "$desktop_file" > /dev/null
}
