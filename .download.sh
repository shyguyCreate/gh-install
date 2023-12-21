#!/bin/sh

#Checks to prevent failure
[ -z "$installer_dir" ] && echo "Error: script run independently" && exit 1

#Get online tag
. "$installer_dir/.update.sh"

#Clean cache with folder excluded
. "$installer_dir/.clean-cache.sh"

#Checks to prevent failure
[ -z "$package_name" ] && echo "Error: package name not specified" && exit 1
[ -z "$package_repo" ] && echo "Error: github repo not specified" && exit 1
[ -z "$package_for_any_arch" ] \
    && [ -z "$package_for_x64" ] \
    && [ -z "$package_for_arm64" ] \
    && [ -z "$package_for_arm32" ] \
    && [ -z "$package_for_x32" ] \
    && echo "Error: package match not specified" && exit 1
[ -z "$ignore_hash_flag" ] && echo "Error: script run independently" && exit 1

#Set cache directory for files download
package_cache="$cache_dir/${package_name}-${online_tag}"
[ ! -d "$package_cache" ] && sudo mkdir -p "$package_cache"

#Set hashes empty
package_hash=""
hash_expected=""

#If match for all architectures is passed
if [ -n "$package_for_any_arch" ]; then
    #Set it to be the match
    package_match="$package_for_any_arch"
else
    #Check architecture
    system_arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

    #Change to more readable form
    case "$system_arch" in
        x86_64) system_arch="x64" ;;
        arm64 | aarch64) system_arch="arm64" ;;
        armv*) system_arch="arm32" ;;
        i?86) system_arch="x32" ;;
    esac

    #Set package match based on architecture
    case $system_arch in
        "x64") package_match="$package_for_x64" ;;
        "arm64") package_match="$package_for_arm64" ;;
        "arm32") package_match="$package_for_arm32" ;;
        "x32") package_match="$package_for_x32" ;;
    esac

    #Exit if package match is empty
    [ -z "$package_match" ] && echo "Error: Package match not available for $system_arch" && exit 1
fi

#Get the package url by opening the .api.json file and searching with regex
package_url="$(grep "\"browser_download_url.*/$package_match\"" "$api_response" | cut -d \" -f 4)"

#Exit if package url is empty
[ -z "$package_url" ] && echo "Error: Package match did not match any release file" && exit 1

#Set path to cache with the name found in the url
package_file="$package_cache/${package_url##*/}"

#If hash extension is set append to package file
[ -n "$hash_extension" ] && hash_file="$(basename "$package_file").${hash_extension}"

#Check if hash file is set and should be ignore
if [ -n "$hash_file" ] && [ "$ignore_hash_flag" = false ]; then

    #Get the hash url by opening the .api.json file and searching with regex
    hash_url="$(grep "\"browser_download_url.*/$hash_file\"" "$api_response" | cut -d \" -f 4)"

    #Exit if hash url is empty
    [ -z "$hash_url" ] && echo "Error: Hash file did not match any release file" && exit 1

    #Set path to cache with the name found in the url
    hash_file="$package_cache/${hash_url##*/}"

    #Download if hash file does not exists
    if [ ! -f "$hash_file" ]; then
        #Start download
        sudo curl -Lf --progress-bar "$hash_url" -o "$hash_file"
    fi

    #Exit if hash file does not exists after download
    [ ! -f "$hash_file" ] && echo "Error: Hash file was not downloaded" && exit 1

    #Get hash inside of the hash file
    hash_expected="$(grep "$(basename "$package_file")" "$hash_file" || cat "$hash_file")"

    #Remove filename from hash and set lo lowercase
    hash_expected="$(echo "$hash_expected" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')"

    #If hash algorithm is not set, use hash file extension
    [ -z "$hash_algorithm" ] && hash_algorithm="${hash_file##*.}"

    get_package_hash()
    {
        #Get hash of the package file
        case "$hash_algorithm" in
            b2) package_hash="$(b2sum "$package_file")" ;;
            sha1) package_hash="$(sha1sum "$package_file")" ;;
            sha224) package_hash="$(sha224sum "$package_file")" ;;
            sha256) package_hash="$(sha256sum "$package_file")" ;;
            sha384) package_hash="$(sha384sum "$package_file")" ;;
            sha512) package_hash="$(sha512sum "$package_file")" ;;
            md5) package_hash="$(md5sum "$package_file")" ;;
            *) echo "Error: Hash algorithm not specified" && exit 1 ;;
        esac

        #Remove filename from hash and set lo lowercase
        package_hash="$(echo "$package_hash" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')"
    }

    #Get hashes if package file is already downloaded
    [ -f "$package_file" ] && get_package_hash
fi

#Download if file does not exists or if hashes do not match
if [ ! -f "$package_file" ] || [ "$package_hash" != "$hash_expected" ]; then
    #Start download
    sudo curl -Lf --progress-bar "$package_url" -o  "$package_file"
fi

#Exit if package file does not exists after download
[ ! -f "$package_file" ] && echo "Error: File was not downloaded" && exit 1

#Compare hashes after downloading package file
if [ -n "$hash_expected" ]; then
    #Get hash of package file
    get_package_hash

    #Exit if hashes do not match
    if [ "$package_hash" != "$hash_expected" ]; then
        echo "Error: Hashes do not match"
        echo " Package hash:  $package_hash"
        echo " Expected hash: $hash_expected"
        exit 1
    fi
fi
