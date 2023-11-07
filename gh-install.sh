#!/bin/sh

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -f to force installation"
    echo "  -i to reinstall program"
    echo "  -r to remove/uninstall programs"
    echo "  -u to update programs"
    echo "  -y to refresh github api response"
}

usage()
{
    echo "Usage:"
    echo "  gh-install all [FLAGS]"
    echo "  gh-install list"
    echo "  gh-install search [PROGRAMS]"
    echo "  gh-install [FLAGS] [PROGRAMS]"
    echo ""
    echo "Flags:"
    usage_flags
    exit
}

#Iterate over all apps scripts
allCommand()
{
    #Check that flags passed are valid
    while getopts ":cfiruy" opt; do
        case $opt in
            c | f | i | r | u | y) ;;
            *)
                echo "Usage: gh-install all [FLAGS]"
                usage_flags
                exit
                ;;
        esac
    done
    #Execute all program scripts
    for script in "$(dirname "$0")"/apps/*.sh; do
        $script "$@"
    done
    exit
}

#Print all apps scripts available
listCommand()
{
    for script in "$(dirname "$0")"/apps/*.sh; do
        basename "$script" .sh
    done
    exit
}

#Print all apps scripts available
searchCommand()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        echo "Usage: gh-install search [PROGRAMS]"
    else
        #Iterate over all arguments and search for leading match
        for argument in "$@"; do
            for script in "$(dirname "$0")"/apps/"${argument}"*.sh; do
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
#Save flags that are needed for the programs script
program_flags="-"
while getopts ":cfiruy" opt; do
    case $opt in
        c) program_flags="${program_flags}c" ;;
        f) program_flags="${program_flags}f" ;;
        i) program_flags="${program_flags}i" ;;
        r) program_flags="${program_flags}r" ;;
        u) program_flags="${program_flags}u" ;;
        y) program_flags="${program_flags}y" ;;
        *) usage ;;
    esac
done

#Skip flags in script arguments
shift "$((OPTIND - 1))"

#Reset getopts automatic variable
OPTIND=1

#Print usage if flag is not passed
if [ "$program_flags" = "-" ]; then
    echo "here"
    usage
fi
#Print usage if flag is passed but no program
if [ $# = 0 ]; then
    echo "here2"
    echo "Usage: gh-install [FLAGS] [PROGRAMS]"
    exit
fi

#Pass arguments placed after flags
#And execute script if argument match with script name
for argument in "$@"; do
    did_match=false
    #Get argument match from apps folder
    for script in "$(dirname "$0")"/apps/*.sh; do
        #Check if argument and program are the same
        if [ "$argument" = "$(basename "$script" .sh)" ]; then
            $script "$program_flags"
            did_match=true
            break
        fi
    done
    #Print if argument and program matched
    if [ "$did_match" = false ]; then
        echo "$argument is not available"
    fi
done
