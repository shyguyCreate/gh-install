#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -f to force installation"
    echo "  -r to remove/uninstall programs"
    echo "  -u to update programs"
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
removeFlag=false
updateFlag=false
refreshFlag=false
while getopts ":cfruy" opt; do
    case $opt in
        c) cleanFlag=true ;;
        f) forceFlag=true ;;
        r) removeFlag=true ;;
        u) updateFlag=true ;;
        y) refreshFlag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Test if -c flag was passed
if [ "$cleanFlag" = true ]; then
    #Set cache directory to clean
    cacheDir="/var/cache/gh-install/$program_file"
    [ -d "$cacheDir" ] && sudo rm -rf "$cacheDir"/*
fi

#Set the root of the install directory based on type of program
case "$program_type" in
    "bin") installDir="/opt" ;;
    "font") installDir="/usr/local/share/fonts" ;;
esac

#Make parent directory for install
[ ! -d "$installDir" ] && sudo mkdir -p "$installDir"

#Test if -r flag was passed
if [ "$removeFlag" = true ]; then
    #Remove contents if already installed
    find "$installDir" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \;
fi

#Exit if -c or -r flag was passed
if [ "$cleanFlag" = true ] || [ "$removeFlag" = true ]; then
    exit
fi

#Get the current version of the program
local_tag=$(find "$installDir" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -printf '%f' -quit | sed "s,${program_file}-,,g")

#File to save the tag_name
api_response="/tmp/${program_file}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" > "$api_response"
fi

#Save tag_name to variable
online_tag=$(grep tag_name "$api_response" | cut -d \" -f 4)

#Start installation if github version is not equal to installed version
#Or if program is not installed or if force flag is passed
if [ "$online_tag" != "$local_tag" ] && [ "$updateFlag" = true ] || [ -z "$local_tag" ] || [ "$forceFlag" = true ]; then
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
