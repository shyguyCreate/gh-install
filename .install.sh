#!/bin/sh

#Add flags to script
checkFlag=false
forceFlag=false
refreshFlag=false
while getopts ":cfy" opt; do
    case $opt in
        c) checkFlag=true ;;
        f) forceFlag=true ;;
        y) refreshFlag=true ;;
        *)
            echo "-c to check available updates"
            echo "-f to force installation"
            echo "-y to refresh github tag"
            ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

save_latest_tag()
{
    #File to save the tag_name
    tag_tmp_file="/tmp/tag_name_$program_file"

    #Get latest tag_name from github api
    if [ ! -f "$tag_tmp_file" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
        curl -s "https://api.github.com/repos/$repo/releases/latest" \
            | grep tag_name \
            | cut -d \" -f 4 \
            | xargs > "$tag_tmp_file"
    fi
}

get_latest_tag()
{
    #Save tag_name to variable
    tag_name=$(cat "$tag_tmp_file")
}

set_install_dir()
{
    #Set the install directory with github tag added to its name
    installDir="$installDir/${program_file}-${tag_name}"
}

get_current_version()
{
    #Get the current version of the program
    current_version=$(find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -printf '%f' -quit | sed "s,${program_file}-,,g")
}

downlaod_program()
{
    echo "Downloading $program_name"

    if [ -n "$download_match" ]; then
        #Download binaries
        curl -s "https://api.github.com/repos/$repo/releases/latest" \
            | grep "\"browser_download_url.*/$download_match\"" \
            | cut -d \" -f 4 \
            | xargs curl -Lf --progress-bar -o "$program_tmp_file"
    elif [ -n "$download_file" ]; then
        curl -Lf --progress-bar "https://github.com/$repo/releases/latest/download/$download_file" -o "$program_tmp_file"
    else
        echo "Download match or file not specified"
    fi
}

extract_program()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$installDir"
    eval "sudo tar $1"
}

copy_program()
{
    #Copy program file to folder installation
    sudo mkdir -p "$installDir"
    sudo cp "$program_tmp_file" "$installDir"
}

change_program_permission()
{
    #Change execute permissions
    sudo chmod +x "$program_binary"
}

install_program()
{
    printf "Begin %s installation..." "$program_name"

    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$program_binary" /usr/local/bin

    [ -f "/usr/local/bin/$program_file" ] && printf "Finished\n" || printf "Failed\n"
}

install_font()
{
    printf "Begin %s installation..." "$program_name"

    #Install fonts globally
    find "$1" -maxdepth 1 -mindepth 1 -type f -name "$2" -exec sudo cp '{}' "$installDir" \;

    [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"
}

uninstall_old_version()
{
    printf "Uninstalling old %s version..." "$program_name"

    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+

    printf "Finished\n"
}

add_bash_completion()
{
    #Add completions for bash
    completion_file="$1"
    sudo mkdir -p /usr/local/share/bash-completion/completions
    sudo cp "$completion_file" /usr/local/share/bash-completion/completions
}

add_zsh_completion()
{
    #Add completions for zsh
    completion_file="$1"
    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo cp "$completion_file" /usr/local/share/zsh/site-functions
}

add_fish_completion()
{
    #Add completions for fish
    completion_file="$1"
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    sudo cp "$completion_file" /usr/local/share/fish/vendor_completions.d
}

add_image()
{
    #Add application image file
    image_file="$1"
    sudo mkdir -p /usr/local/share/pixmaps
    sudo cp "$image_file" /usr/local/share/pixmaps
}

add_internet_image()
{
    #Add application image file
    url="$1"
    sudo mkdir -p "$(dirname "$program_image_file")"
    sudo curl -s "$url" -o "$program_image_file"
}

add_old_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    eval "$program_file completion -s bash | sudo tee /usr/local/share/bash-completion/completions/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    eval "$program_file completion -s zsh | sudo tee /usr/local/share/zsh/site-functions/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    eval "$program_file completion -s fish | sudo tee /usr/local/share/fish/vendor_completions.d/$program_file.fish > /dev/null"
}

add_new_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    eval "$program_file completion bash | sudo tee /usr/local/share/bash-completion/completions/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    eval "$program_file completion zsh | sudo tee /usr/local/share/zsh/site-functions/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    eval "$program_file completion fish | sudo tee /usr/local/share/fish/vendor_completions.d/$program_file.fish > /dev/null"
}

add_desktop_file()
{
    #Add application .desktop file
    sudo mkdir -p "$(dirname "$program_desktop_file")"
    echo "$desktop_file_content" | sudo tee "$program_desktop_file" > /dev/null
}

###############################################################
############################ START ############################
###############################################################

save_latest_tag
get_latest_tag
set_install_dir
get_current_version

#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ "$checkFlag" = false ] || [ "$forceFlag" = true ]; then

    #Check if program is already downloaded
    if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
        downlaod_program
    fi

    #Continue in parent script
    return

elif [ "$checkFlag" = true ] && [ "$tag_name" = "$current_version" ]; then
    echo "No update found for $program_name"

elif [ "$checkFlag" = true ] && [ "$tag_name" != "$current_version" ]; then
    echo "Update found for $program_name"

else
    echo "$program_name is up to date"
fi

#End this and parent script
exit
