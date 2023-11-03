#!/bin/sh

usage()
{
    echo "Usage: gh-install [OPTIONS] [PROGRAM]"
    echo "  -a to apply to all programs"
    echo "  -l to list all programs"
    echo "  -c to check available updates"
    echo "  -f to force installation"
    echo "  -y to refresh github api response"
    exit
}

allFlag()
{
    #Iterate over all bin and fonts scripts
    for script in "$(dirname "$0")"/bin/*.sh "$(dirname "$0")"/fonts/*.sh; do
        $script "$@"
    done
    exit
}

listFlag()
{
    #Print all bin and fonts scripts available
    echo "BIN"
    echo "------"
    for script in "$(dirname "$0")"/bin/*.sh; do
        basename "$script" .sh
    done
    echo ""
    echo "FONTS"
    echo "------"
    for script in "$(dirname "$0")"/fonts/*.sh; do
        basename "$script" .sh
    done
    exit
}

#Add flags to script
while getopts ":acfly" opt; do
    case $opt in
        a) allFlag "$@" ;;
        l) listFlag ;;
        c | f | y) ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Print usage if no flag is passed
usage
