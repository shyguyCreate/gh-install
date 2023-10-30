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
    online_tag=$(cat "$tag_tmp_file")
}

set_install_dir()
{
    #Set the install directory with github tag added to its name
    installDir="$installDir/${program_file}-${online_tag}"
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

extract_gz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$installDir"
    eval "sudo tar zxf $program_tmp_file -C $installDir $1"
}

extract_xz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$installDir"
    eval "sudo tar Jxf $program_tmp_file -C $installDir $1"
}

copy_program()
{
    #Copy program file to folder installation
    sudo mkdir -p "$installDir"
    sudo cp "$program_tmp_file" "$installDir"
}

uninstall_old_version()
{
    printf "Uninstalling old %s version..." "$program_name"

    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+

    printf "Finished\n"
}

#Source file with functions based on type
case "$type" in
    "bin") . "$(dirname "$0")/.bin.sh" ;;
    "font") . "$(dirname "$0")/.font.sh" ;;
esac

###############################################################
############################ START ############################
###############################################################

save_latest_tag
get_latest_tag
set_install_dir
get_current_version

#Start installation if github version is not equal to installed version
if [ "$online_tag" != "$current_version" ] && [ "$checkFlag" = false ] || [ "$forceFlag" = true ]; then

    #Check if program is already downloaded
    if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
        downlaod_program
    fi

    #Continue in parent script
    return

elif [ "$checkFlag" = true ] && [ "$online_tag" = "$current_version" ]; then
    echo "No update found for $program_name"

elif [ "$checkFlag" = true ] && [ "$online_tag" != "$current_version" ]; then
    echo "Update found for $program_name"

else
    echo "$program_name is up to date"
fi

#End this and parent script
exit
