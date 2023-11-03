#!/bin/sh

#Add flags to script
allFlag=false
while getopts ":acfy" opt; do
    case $opt in
        a) allFlag=true ;;
        c | f | y) ;;
        *)
            echo "-a to apply to all programs"
            echo "-c to check available updates"
            echo "-f to force installation"
            echo "-y to refresh github api response"
            ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Iterate over all bin and fonts scripts
if [ "$allFlag" = true ]; then
    for script in "$(dirname "$0")"/bin/*.sh "$(dirname "$0")"/fonts/*.sh; do
        $script "$@"
    done
fi
