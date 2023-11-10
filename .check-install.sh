#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -d to download only"
    echo "  -f to force installation"
    echo "  -i to install/update programs"
    echo "  -r to reinstall program"
    echo "  -u to uninstall programs"
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
downloadFlag=false
forceFlag=false
installFlag=false
reinstallFlag=false
uninstallFlag=false
refreshFlag=false
while getopts ":cdfiruy" opt; do
    case $opt in
        c) cleanFlag=true ;;
        d) downloadFlag=true ;;
        f) forceFlag=true ;;
        i) installFlag=true ;;
        r) reinstallFlag=true ;;
        u) uninstallFlag=true ;;
        y) refreshFlag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Test if -c flag was passed
if [ "$cleanFlag" = true ]; then
    #Set cache directory to clean
    cacheDir="/var/cache/gh-install"
    [ ! -d "$cacheDir" ] && sudo mkdir -p "$cacheDir"

    #Clean cache directories of currents program
    find "$cacheDir" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -exec sudo rm -rf '{}' \;
fi

#Set the root of the install directory based on type of program
case "$program_type" in
    "bin") installDir="/opt" ;;
    "font") installDir="/usr/local/share/fonts" ;;
esac

#Make parent directory for install
[ ! -d "$installDir" ] && sudo mkdir -p "$installDir"

#Test if -r flag was passed
if [ "$uninstallFlag" = true ]; then
    #Remove contents if already installed
    find "$installDir" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -exec sudo rm -rf '{}' \;
fi

#Exit if -c or -r flag was passed
[ "$cleanFlag" = true ] || [ "$uninstallFlag" = true ] && exit

#Get the current version of the program
local_tag=$(find "$installDir" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -printf '%f' -quit | sed "s,${program_file}-,,g")

#File to save the tag_name
api_response="/tmp/${program_file}.api.json"

#Get latest release from the github api response
if [ ! -f "$api_response" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" -o "$api_response"
fi

#Save tag_name to variable
online_tag=$(grep tag_name "$api_response" | cut -d \" -f 4)

#Start installation if github version is not equal to installed version
#Or if program is not installed or if -rdf flag is passed
if [ "$downloadFlag" = true ]; then
    echo "Begin $program_name download..."

elif [ "$reinstallFlag" = true ]; then
    echo "Begin $program_name reinstallation..."

elif [ "$online_tag" != "$local_tag" ] && [ "$installFlag" = true ] || [ -z "$local_tag" ] || [ "$forceFlag" = true ]; then
    echo "Begin $program_name installation..."

elif [ "$installFlag" = false ] && [ "$online_tag" = "$local_tag" ]; then
    echo "No update found for $program_name"
    exit
elif [ "$installFlag" = false ] && [ "$online_tag" != "$local_tag" ]; then
    echo "Update found for $program_name"
    exit
else
    echo "$program_name is up to date"
    exit
fi
