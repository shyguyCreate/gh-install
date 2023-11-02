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
if [ "$online_tag" != "$local_tag" ] && [ "$checkFlag" = false ] || [ "$forceFlag" = true ]; then
    echo "Begin $program_name installation..."

elif [ "$checkFlag" = true ] && [ "$online_tag" = "$local_tag" ]; then
    echo "No update found for $program_name"
    exit
elif [ "$checkFlag" = true ] && [ "$online_tag" != "$local_tag" ]; then
    echo "Update found for $program_name"
    exit
else
    echo "$program_name is up to date"
    exit
fi
