#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -f to force installation"
    echo "  -u to update packages"
    echo "  -y to refresh github api response"
}

usage()
{
    echo "Flags:"
    usage_flags
    exit
}

#Add flags to script
cleanFlag=false
forceFlag=false
updateFlag=false
refreshFlag=false
while getopts ":cfuy" opt; do
    case $opt in
        c) cleanFlag=true ;;
        f) forceFlag=true ;;
        u) updateFlag=true ;;
        y) refreshFlag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

clean_cache()
{
    #Set cache directory to clean
    cacheDir="/var/cache/gh-install/$program_file"
    [ -d "$cacheDir" ] && sudo rm -rf "$cacheDir"/*
}

#Test if -c flag was passed
if [ "$cleanFlag" = true ]; then
    clean_cache
    #Exit after cleaning
    exit
fi

#File to save the tag_name
api_response="/tmp/${program_file}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" > "$api_response"
fi

#Save tag_name to variable
online_tag=$(grep tag_name "$api_response" | cut -d \" -f 4)

#Set the root of the install directory based on type of program
case "$program_type" in
    "bin") installDir="/opt" ;;
    "font") installDir="/usr/local/share/fonts" ;;
esac

#Make parent directory for install
[ ! -d "$installDir" ] && sudo mkdir -p "$installDir"

#Set the install directory with github tag added to its name
installDir="$installDir/${program_file}-${online_tag}"

#Get the current version of the program
local_tag=$(find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -printf '%f' -quit | sed "s,${program_file}-,,g")

#Start installation if github version is not equal to installed version
if [ "$online_tag" != "$local_tag" ] && [ "$updateFlag" = true ] || [ "$forceFlag" = true ]; then
    echo "Begin $program_name installation..."

elif [ "$updateFlag" = false ] && [ "$online_tag" = "$local_tag" ]; then
    echo "No update found for $program_name"
    exit
elif [ "$updateFlag" = false ] && [ "$online_tag" != "$local_tag" ]; then
    echo "Update found for $program_name"
    exit
else
    echo "$program_name is up to date"
    exit
fi
