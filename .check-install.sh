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
tag_tmp_file="/tmp/tag_name_$program_file"

#Get latest tag_name from github api
if [ ! -f "$tag_tmp_file" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep tag_name \
        | cut -d \" -f 4 \
        | xargs > "$tag_tmp_file"
fi

#Save tag_name to variable
online_tag=$(cat "$tag_tmp_file")

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
