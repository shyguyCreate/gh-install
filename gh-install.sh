#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -d to download only"
    echo "  -f to force installation"
    echo "  -i to (re)install package"
    echo "  -r to remove package"
    echo "  -u to update package"
    echo "  -x to ignore hashes"
    echo "  -y to refresh github api response"
}

usage()
{
    echo "Usage:"
    echo "  gh-install all [FLAGS]"
    echo "  gh-install list"
    echo "  gh-install search [PACKAGES]"
    echo "  gh-install [FLAGS] [PACKAGES]"
    echo ""
    echo "Flags:"
    usage_flags
    exit
}

#Iterate over all packages scripts
allCommand()
{
    #Check that flags passed are valid
    while getopts ":cdfiruxy" opt; do
        case $opt in
            c | d | f | i | r | u | x | y) ;;
            *)
                echo "Usage: gh-install all [FLAGS]"
                usage_flags
                exit
                ;;
        esac
    done
    #Execute all package scripts
    for script in "$(dirname "$0")"/packages/*.sh; do
        $script "$@"
    done
    exit
}

#Print all packages scripts available
listCommand()
{
    for script in "$(dirname "$0")"/packages/*.sh; do
        basename "$script" .sh
    done
    exit
}

#Print all packages scripts available
searchCommand()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        echo "Usage: gh-install search [PACKAGES]"
    else
        #Iterate over all arguments and search for leading match
        for argument in "$@"; do
            for script in "$(dirname "$0")"/packages/"${argument}"*.sh; do
                [ -f "$script" ] && basename "$script" .sh
            done
        done
    fi
    exit
}

#Check for command match
case "$1" in
    "all")
        shift 1
        allCommand "$@"
        ;;
    "list") listCommand ;;
    "search")
        shift 1
        searchCommand "$@"
        ;;
esac

#Check for flag match
#Save flags that are needed for the packages script
program_flags="-"
while getopts ":cdfiruxy" opt; do
    case $opt in
        c) program_flags="${program_flags}c" ;;
        d) program_flags="${program_flags}d" ;;
        f) program_flags="${program_flags}f" ;;
        i) program_flags="${program_flags}i" ;;
        r) program_flags="${program_flags}r" ;;
        u) program_flags="${program_flags}u" ;;
        x) program_flags="${program_flags}x" ;;
        y) program_flags="${program_flags}y" ;;
        *) usage ;;
    esac
done

#Skip flags in script arguments
shift "$((OPTIND - 1))"

#Reset getopts automatic variable
OPTIND=1

#Print usage if flag and package are not passed
if [ "$program_flags" = "-" ] && [ $# = 0 ]; then
    usage
fi
#Print usage if flag is passed but no package
if [ "$program_flags" != "-" ] && [ $# = 0 ]; then
    echo "Usage: gh-install [FLAGS] [PACKAGES]"
    exit
fi

#Pass arguments placed after flags
#And execute script if argument match with script name
for argument in "$@"; do
    did_match=false
    #Get argument match from packages folder
    for script in "$(dirname "$0")"/packages/*.sh; do
        #Check if argument and package are the same
        if [ "$argument" = "$(basename "$script" .sh)" ]; then
            $script "$program_flags"
            did_match=true
            break
        fi
    done
    #Print if argument and package matched
    if [ "$did_match" = false ]; then
        echo "'$argument' is not available"
    fi
done
