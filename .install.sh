#!/bin/sh

#### Section 1 ####

download_program()
{
    #If match for all architectures is passed
    if [ -n "$download_all_arch" ]; then
        #Set it to be the match
        download_match="$download_all_arch"
    else
        #Check architecture
        system_arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

        #Change to more readable form
        case "$system_arch" in
            x86_64) system_arch="x64" ;;
            armv*) system_arch="arm32" ;;
            arm64 | aarch64) system_arch="arm64" ;;
            i?86) system_arch="x32" ;;
        esac

        #Set download match based on architecture
        case $system_arch in
            "x64") download_match=$download_x64 ;;
            "arm32") download_match=$download_arm32 ;;
            "arm64") download_match=$download_arm64 ;;
            "x32") download_match=$download_x32 ;;
        esac
        #Exit if download match is empty
        [ -z "$download_match" ] && echo "Download match not available for $system_arch" && exit 1
    fi

    #Get the download url by opening the .api.json file and searching with regex
    url=$(grep "\"browser_download_url.*/$download_match\"" "$api_response" | cut -d \" -f 4)

    #Exit if url is empty
    [ -z "$url" ] && echo "Download match did not match any release file" && exit 1

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

install_program()
{
    install_bin()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Program binary location not specified" && exit 1

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
        find "$installDir" -maxdepth 1 -mindepth 1 -type f -not -name "$font_name" -exec sudo rm -rf '{}' \;
    }

    #Choose which function to pick
    case "$program_type" in
        "bin") install_bin "$1" ;;
        "font") install_font "$1" ;;
    esac
}

#### Section 4 ####

uninstall_old_version()
{
    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \;
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

    add_completion_file()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Completion file not specified" && exit 1

        #Add completion file to directory based on shell passed
        completion_file="$1"
        completion_dir="$2"
        sudo cp "$completion_file" "$completion_dir"
    }

    add_old_Cobra_completion()
    {
        #Add completions for bash/zsh/fish
        eval "$program_file completion -s bash | sudo tee $bash_completion_dir/$program_file > /dev/null"
        eval "$program_file completion -s zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"
        eval "$program_file completion -s fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
    }

    add_new_Cobra_completion()
    {
        #Add completions for bash/zsh/fish
        eval "$program_file completion bash | sudo tee $bash_completion_dir/$program_file > /dev/null"
        eval "$program_file completion zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"
        eval "$program_file completion fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
    }

    #Exit if no argument was passed
    [ -z "$1" ] && echo "Completion shell not specified" && exit 1

    #Choose which function to pick
    case "$1" in
        "bash") add_completion_file "$2" "$bash_completion_dir" ;;
        "zsh")  add_completion_file "$2" "$zsh_completion_dir"  ;;
        "fish") add_completion_file "$2" "$fish_completion_dir" ;;
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
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Image location not specified" && exit 1
        #Add application image file from computer
        local_image_dir="$1"
        sudo mkdir -p "$image_dir"
        sudo cp "$local_image_dir" "$image_dir/$image_name"
    }

    add_online_image()
    {
        #Exit if no argument was passed
        [ -z "$1" ] && echo "Url not specified" && exit 1
        #Add application image file from internet
        url="$1"
        sudo mkdir -p "$image_dir"
        sudo curl -s "$url" -o "$image_dir/$image_name"
    }

    #Exit if no argument was passed
    [ -z "$1" ] && echo "Image type (local|onine) not specified" && exit 1

    #Choose which function to pick
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

    #Exit if argument is incorrect
    [ "$1" != true ] && [ "$1" != false ] && echo "Argument only accepts true or false" && exit 1

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
