#!/bin/sh

usage()
{
    echo "Usage: gh-install [OPTIONS] [PROGRAMS]"
    echo "  -a to apply to all programs"
    echo "  -l to list all programs"
    echo "  -c to check available updates"
    echo "  -f to force installation"
    echo "  -y to refresh github api response"
    exit
}

#Iterate over all bin and fonts scripts
allFlag()
{
    for script in "$(dirname "$0")"/bin/*.sh "$(dirname "$0")"/fonts/*.sh; do
        $script "$@"
    done
}

#Print all bin and fonts scripts available
listFlag()
{
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
}

_allFlag=false
_listFlag=false
_otherFlag=false
#Add flags to script
while getopts ":acfly" opt; do
    case $opt in
        a) _allFlag=true ;;
        l) _listFlag=true ;;
        c | f | y) _otherFlag=true ;;
        *) usage ;;
    esac
done

#Reset getopts automatic variable
OPTIND=1

#Specify flag order of importance
if [ "$_listFlag" = true ]; then
    listFlag
elif [ "$_allFlag" = true ]; then
    allFlag "$@"
elif [ "$_otherFlag" != true ]; then
    #Print usage if no flag is passed
    usage
fi
