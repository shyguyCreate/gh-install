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

get_install_dir()
{
    #Set the install directory with github tag added to its name
    installDir="/opt/${program_file}-${tag_name}"
}

get_current_version()
{
    #Get the current version of the program
    current_version=$(find /opt -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -printf '%f' -quit | sed "s,${program_file}-,,g")
}

downlaod_program()
{
    echo "Downloading $program_name"

    #Download binaries
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep "\"browser_download_url.*/$download_match\"" \
        | cut -d \" -f 4 \
        | xargs curl -Lf --progress-bar -o "$program_tmp_file"
}

uninstall_old_version()
{
    printf "Uninstalling old %s version..." "$program_name"

    #Remove contents if already installed
    find /opt -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+

    printf "Finished\n"
}

extract_program()
{
    #Create folder for contents
    sudo mkdir -p "$installDir"

    #Expand tar file to folder
    echo "sudo tar zxf $program_tmp_file -C $installDir $1"
    eval "sudo tar zxf $program_tmp_file -C $installDir $1"
}

install_program()
{
    printf "Begin %s installation..." "$program_name"

    #Change execute permissions
    sudo chmod +x "$installDir/bin/$program_file"

    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$installDir/bin/$program_file" /usr/local/bin

    [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"
}

add_bash_completion()
{
    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    sudo cp "$completion_bash" /usr/local/share/bash-completion/completions
}

add_zsh_completion()
{
    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo cp "$completion_zsh" /usr/local/share/zsh/site-functions
}

add_fish_completion()
{
    #Add completions for fish
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    sudo cp "$completion_fish" /usr/local/share/fish/vendor_completions.d
}

add_image()
{
    #Add application image file
    sudo mkdir -p /usr/local/share/pixmaps
    sudo cp "$program_image" /usr/local/share/pixmaps
}

add_Cobra_completions()
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

set_desktop_file()
{
    #Create applications folder
    sudo mkdir -p /usr/local/share/applications

    printf "Writing %s desktop file..." "$program_name"

    #Write application .desktop file
    echo "$desktop_file_content" | sudo tee "$program_desktop_file" > /dev/null

    printf "Finished\n"
}

###############################################################
############################ START ############################
###############################################################

save_latest_tag
get_latest_tag
get_install_dir
get_current_version

#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ "$checkFlag" = false ] || [ "$forceFlag" = true ]; then

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
