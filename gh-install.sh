#!/bin/sh

#Save path to root of the repo
installer_dir="$(dirname "$0")"

#Set directory to save package version
lib_dir="/var/lib/gh-install"
[ ! -d "$lib_dir" ] && sudo mkdir -p "$lib_dir"

usage_flags()
{
    echo "  -c to clean cache"
    echo "  -d to download only"
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

get_packages()
{
    #Get the all packages from packages folder
    for script in "$installer_dir"/packages/*.sh; do
        basename "$script" .sh
    done
}

search_matching_packages()
{
    #Repeat for each argument
    for argument in "$@"; do
        #Get argument match from packages folder
        [ -f "$installer_dir/packages/${argument}.sh" ] \
            && echo "$argument" \
            || echo "No package with name '$argument'" >&2
    done
}

get_installed_packages()
{
    #Get the all packages in lib directory
    find "$lib_dir" -maxdepth 1 -mindepth 1 -type f -printf '%f\n' | sed "s,-[^-]*$,,g" | sort -u
}

search_matching_installed_packages()
{
    #Repeat for each argument
    for argument in "$@"; do
        #Get argument match from lib directory
        for file in "$lib_dir/$argument-"*; do
            [ -f "$file" ] \
                && echo "$argument" \
                || echo "No package installed with name '$argument'" >&2
        done
    done
}

#Iterate over all packages scripts
all_command()
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
    for script in "$installer_dir"/packages/*.sh; do
        $script "$@"
    done
    exit
}

list_packages()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        get_installed_packages
    else
        search_matching_installed_packages "$@"
    fi
    exit
}

search_packages()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        get_packages
    else
        search_matching_packages "$@"
    fi
    exit
}

#Check for command match
case "$1" in
    "all")
        shift 1
        all_command "$@"
        ;;
    "download")
        shift 1
        for package in $(search_matching_packages "$@"); do
            "$installer_dir/packages/${package}.sh"
        done
        ;;
    "list")
        shift 1
        list_packages "$@"
        ;;
    "search")
        shift 1
        search_packages "$@"
        ;;
    "update")
        for package in $(get_installed_packages); do
            [ -f "$installer_dir/packages/${package}.sh" ] && "$installer_dir/packages/${package}.sh"
        done
        ;;
esac

#Check for flag match
#Save flags that are needed for the packages script
package_flags="-"
while getopts ":cdfiruxy" opt; do
    case $opt in
        c) package_flags="${package_flags}c" ;;
        d) package_flags="${package_flags}d" ;;
        f) package_flags="${package_flags}f" ;;
        i) package_flags="${package_flags}i" ;;
        r) package_flags="${package_flags}r" ;;
        u) package_flags="${package_flags}u" ;;
        x) package_flags="${package_flags}x" ;;
        y) package_flags="${package_flags}y" ;;
        *) usage ;;
    esac
done

#Skip flags in script arguments
shift "$((OPTIND - 1))"

#Reset getopts automatic variable
OPTIND=1

#Print usage if flag and package are not passed
if [ "$package_flags" = "-" ] && [ $# = 0 ]; then
    usage
fi
#Print usage if flag is passed but no package
if [ "$package_flags" != "-" ] && [ $# = 0 ]; then
    echo "Usage: gh-install [FLAGS] [PACKAGES]"
    exit
fi

#Pass arguments placed after flags
#And execute script if argument match with script name
for argument in "$@"; do
    did_match=false
    #Get argument match from packages folder
    for script in "$installer_dir"/packages/*.sh; do
        #Check if argument and package are the same
        if [ "$argument" = "$(basename "$script" .sh)" ]; then
            $script "$package_flags"
            did_match=true
            break
        fi
    done
    #Print if argument and package matched
    if [ "$did_match" = false ]; then
        echo "'$argument' is not available"
    fi
done
