#!/bin/sh

#### Section 1 ####

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
        "x64") download_match="$download_x64" ;;
        "arm32") download_match="$download_arm32" ;;
        "arm64") download_match="$download_arm64" ;;
        "x32") download_match="$download_x32" ;;
    esac

    #Exit if download match is empty
    [ -z "$download_match" ] && echo "Download match not available for $system_arch" && exit 1
fi

#Get the download url by opening the .api.json file and searching with regex
url=$(grep "\"browser_download_url.*/$download_match\"" "$api_response" | cut -d \" -f 4)

#Exit if url is empty
[ -z "$url" ] && echo "Download match did not match any release file" && exit 1

#Set cache directory for downloaded files
cacheDir="/var/cache/gh-install/$program_file"
[ ! -d "$cacheDir" ] && sudo mkdir -p "$cacheDir"

#Set path to download file with the name found in the url
download_file="$cacheDir/${url##*/}"

#Download if file does not exits or if force passed
if [ ! -f "$download_file" ] || [ "$forceFlag" = true ]; then
    #Start download
    sudo curl -Lf --progress-bar "$url" -o "$download_file"
fi

#Exit if file does not exits after download
[ ! -f "$download_file" ] && echo "Error when downloading" && exit

#Clean cache from old download files
find "$cacheDir" -maxdepth 1 -mindepth 1 -type f -not -path "$download_file" -exec sudo rm -rf '{}' \;

#Exit if -d flag is passed
[ "$downloadFlag" = true ] && exit
