#!/bin/sh

usage()
{
    echo "Usage: gh-install [OPTIONS] [PROGRAMS]"
    echo "  -a to apply to all programs"
    echo "  -l to list all programs"
    echo "  -s to search for programs"
    echo ""
    echo "Program options:"
    echo "  -c to check available updates"
    echo "  -f to force installation"
    echo "  -y to refresh github api response"
    exit
}

#Iterate over all apps scripts
allFlag()
{
    for script in "$(dirname "$0")"/apps/*.sh; do
        $script "$program_flags"
    done
    exit
}

#Print all apps scripts available
listFlag()
{
    for script in "$(dirname "$0")"/apps/*.sh; do
        basename "$script" .sh
    done
    exit
}

#Print all apps scripts available
searchFlag()
{
    #Print usage if arguments are empty
    [ $# = 0 ] && usage
    #Iterate over all arguments and search for leading match
    for argument in "$@"; do
        for script in "$(dirname "$0")"/apps/"${argument}"*.sh; do
            [ -f "$script" ] && basename "$script" .sh
        done
    done
    exit
}

#Save flags that are needed for the programs script
program_flags="-"

#Add flags to script
_allFlag=false
_listFlag=false
_searchFlag=false
while getopts ":alscfy" opt; do
    case $opt in
        a) _allFlag=true ;;
        l) _listFlag=true ;;
        s) _searchFlag=true ;;
        c) program_flags="${program_flags}c" ;;
        f) program_flags="${program_flags}f" ;;
        y) program_flags="${program_flags}y" ;;
        *) usage ;;
    esac
done

#Save the argument number of flags
flag_arg_num="$((OPTIND - 1))"

#Reset getopts automatic variable
OPTIND=1

#Specify flag order of importance
if [ "$_searchFlag" = true ]; then
    shift $flag_arg_num
    searchFlag "$@"
elif [ "$_listFlag" = true ]; then
    listFlag
elif [ "$_allFlag" = true ]; then
    allFlag "$@"
fi

#Get argument match from bin or fonts folder
execute_program()
{
    for argument in "$@"; do
        did_match=false
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
}

#Skip flags in script arguments
shift $flag_arg_num

if [ $# != 0 ]; then
    #Pass arguments to search for a match with a program
    execute_program "$@"
else
    #Print usage if no flag or program is passed
    usage
fi
