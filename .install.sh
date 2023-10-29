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

install_program()
{
    #Create folder for contents
    sudo mkdir -p "$installDir"

    printf "Begin %s installation..." "$program_name"

    #Expand tar file to folder
    sudo tar zxf "$program_tmp_file" -C "$installDir"

    #Change execute permissions
    sudo chmod +x "$installDir/bin/$program_file"

    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$installDir/bin/$program_file" /usr/local/bin

    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    sudo cp "$installDir/resources/completions/bash/$program_file" /usr/local/share/bash-completion/completions

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo cp "$installDir/resources/completions/zsh/_$program_file" /usr/local/share/zsh/site-functions

    #Copy application image
    sudo mkdir -p /usr/local/share/pixmaps
    sudo cp "$installDir/resources/app/resources/linux/code.png" "/usr/local/share/pixmaps/$program_file.png"

    [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"
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

    #Check if program is already downloaded
    if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
        downlaod_program
    fi

    #Install and uninstall
    install_program
    uninstall_old_version

    #Check if .desktop file exist
    if [ ! -f "$program_desktop_file" ] || [ $forceFlag = true ]; then
        set_desktop_file
    fi

elif [ "$checkFlag" = true ] && [ "$tag_name" = "$current_version" ]; then
    echo "No update found for $program_name"

elif [ "$checkFlag" = true ] && [ "$tag_name" != "$current_version" ]; then
    echo "Update found for $program_name"

else
    echo "$program_name is up to date"
fi
