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
    sudo curl -f --progress-bar "$url" -o "$download_file"
fi

#Exit if file does not exits after download
[ ! -f "$download_file" ] && echo "Error when downloading" && exit

#Test if download file has hashes
[ -n "$trailing_hash" ] && hash_file="$(basename "$download_file").${trailing_hash}"

#Check if hash file was set by trailing or manually
if [ -n "$hash_file" ]; then
    #Add cache dir to hash
    hash_file="$cacheDir/$hash_file"

    #Download hash file
    sudo curl -s "${url}.$trailing_hash" -o "$hash_file"

    #Get hash of the download file
    case "$hash_file" in
        *.sha1) download_file_hash="$(eval "sha1sum $download_file")" ;;
        *.sha256) download_file_hash="$(eval "sha256sum $download_file")" ;;
        *) [ -n "$hash_algorithm" ] && download_file_hash="$(eval "${hash_algorithm}sum $download_file")" ;;
    esac

    #Get hash inside of the download hash file
    download_hash="$(grep "$(basename "$download_file")" "$hash_file" | awk '{print $1}' || cat "$hash_file")"

    #Set hashes to lowercase
    download_file_hash="$download_file_hash | tr '[:upper:]' '[:lower:]')"
    download_hash="$download_hash | tr '[:upper:]' '[:lower:]')"

    #Exit if hashes do not match
    [ "$download_file_hash" != "$hash_file" ] && echo "WARNING: Hashes do not match" && exit
fi

#Clean cache from old download files
find "$cacheDir" -maxdepth 1 -mindepth 1 -type f -not -path "$download_file" -not -name "$hash_file" -exec echo '{}' \;

#Exit if -d flag is passed
[ "$downloadFlag" = true ] && exit
