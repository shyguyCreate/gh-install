#!/bin/sh

#Set cache directory for downloaded files
cacheDir="/var/cache/gh-install/${program_name}-${online_tag}"
[ ! -d "$cacheDir" ] && sudo mkdir -p "$cacheDir"

#Clean cache from old download files
find "$(dirname "$cacheDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_name}-*" -not -path "$cacheDir" -exec sudo rm -rf '{}' \;

#Set hashes empty
download_file_hash=""
download_hash=""

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
    [ -z "$download_match" ] && echo "Error: Download match not available for $system_arch" && exit 1
fi

#Get the download url by opening the .api.json file and searching with regex
download_url=$(grep "\"browser_download_url.*/$download_match\"" "$api_response" | cut -d \" -f 4)

#Exit if download url is empty
[ -z "$download_url" ] && echo "Error: Download match did not match any release file" && exit 1

#Set path to download file with the name found in the url
download_file="$cacheDir/${download_url##*/}"

#Append hash extension to download file if set
[ -n "$hash_extension" ] && hash_file="$(basename "$download_file").${hash_extension}"

#Empty hash file if ignore hash is passed
[ "$hashFlag" = true ] && hash_file=""

#Check if hash file is set
if [ -n "$hash_file" ]; then

    #Get the hash url by opening the .api.json file and searching with regex
    hash_url="$(grep "\"browser_download_url.*/$hash_file\"" "$api_response" | cut -d \" -f 4)"

    #Exit if hash url is empty
    [ -z "$hash_url" ] && echo "Error: Hash file did not match any release file" && exit 1

    #Set path to download file with the name found in the url
    hash_file="$cacheDir/${hash_url##*/}"

    #Download if hash file does not exists or if force passed
    if [ ! -f "$hash_file" ] || [ "$forceFlag" = true ]; then
        #Start download
        sudo curl -Lf --progress-bar "$hash_url" -o "$hash_file"
    fi

    #Exit if hash file does not exists after download
    [ ! -f "$hash_file" ] && echo "Error: Hash file was not downloaded" && exit 1

    #Get hash inside of the download hash file
    download_hash="$(grep "$(basename "$download_file")" "$hash_file" || cat "$hash_file")"

    #Remove filename from hash and set lo lowercase
    download_hash="$(echo "$download_hash" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')"

    get_download_file_hash()
    {
        #Get hash of the download file
        case "$hash_file" in
            *.sha1) download_file_hash="$(eval "sha1sum $download_file")" ;;
            *.sha256) download_file_hash="$(eval "sha256sum $download_file")" ;;
            *) [ -n "$hash_algorithm" ] && download_file_hash="$(eval "${hash_algorithm}sum $download_file")" ;;
        esac

        #Remove filename from hash and set lo lowercase
        download_file_hash="$(echo "$download_file_hash" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')"
    }

    #Get hashes if download file is already installed
    [ -f "$download_file" ] && get_download_file_hash
fi

#Download if file does not exists or if hashes do not match or if force passed
if [ ! -f "$download_file" ] || [ "$download_file_hash" != "$download_hash" ] || [ "$forceFlag" = true ]; then
    #Start download
    sudo curl -Lf --progress-bar "$download_url" -o  "$download_file"
fi

#Exit if file does not exists after download
[ ! -f "$download_file" ] && echo "Error: File was not downloaded" && exit 1

#Compare hashes after downloading file
if [ -n "$hash_file" ]; then
    #Get hash of download file
    get_download_file_hash

    #Exit if hashes do not match
    if [ "$download_file_hash" != "$download_hash" ]; then
        echo "Error: Hashes do not match"
        echo " Package hash:  $download_file_hash"
        echo " Expected hash: $download_hash"
        exit 1
    fi
fi

#Exit if -d flag is passed
[ "$downloadFlag" = true ] && exit
