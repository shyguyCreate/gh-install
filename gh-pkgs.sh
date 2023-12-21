#!/bin/sh

#Save path to root of the repo
installer_dir="$(dirname "$0")"

#Set directory to save package version
lib_dir="/var/lib/gh-pkgs"
[ ! -d "$lib_dir" ] && sudo mkdir -p "$lib_dir"

#Save boolean for script calls
install_command=false
update_command=false

usage_flags()
{
    echo ""
    echo "Flags:"
    echo "  -x to ignore hashes"
    echo "  -y to refresh github api response"
}

usage()
{
    case "$command" in
        "clean")
            echo "Usage: gh-pkgs clean [<packages>]"
            ;;
        "download")
            echo "Usage: gh-pkgs download [<flags>] <packages>"
            usage_flags
            ;;
        "install")
            echo "Usage: gh-pkgs install [<flags>] <packages>"
            usage_flags
            ;;
        "list")
            echo "Usage: gh-pkgs list [<packages>]"
            ;;
        "search")
            echo "Usage: gh-pkgs search [<packages>]"
            ;;
        "uninstall")
            echo "Usage: gh-pkgs uninstall <packages>"
            ;;
        "update")
            echo "Usage: gh-pkgs update [<flags>] [<packages>]"
            usage_flags
            ;;
        *)
            echo "Usage: gh-pkgs <command> [<flags>] [<packages>]"
            echo ""
            echo "Commands:"
            echo "  clean       clean cache directory"
            echo "  download    download package without installing"
            echo "  install     install package"
            echo "  list        list all packages installed"
            echo "  search      search across available packages"
            echo "  uninstall   uninstall package"
            echo "  update      update package"
            usage_flags
            ;;
    esac
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
                && echo "$argument" && break \
                || echo "No package installed with name '$argument'" >&2
        done
    done
}

clean_cache()
{
    if [ $# = 0 ]; then
        #Run clean cache script
        . "$installer_dir/.clean-cache.sh"
    else
        #Execute based on package match
        for package in $(search_matching_packages "$@"); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    echo "Clean cache for $package_name..."
                    . "$installer_dir/.clean-cache.sh"
                )
            fi
        done
    fi
}

download_packages()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        usage
    else
        #Execute based on package match
        for package in $(search_matching_packages "$@"); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    echo "Start $package_name download..."
                    . "$installer_dir/.download.sh"
                )
            fi
        done
    fi
}

install_packages()
{
    install_command=true
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        usage
    else
        #Execute based on package match
        for package in $(search_matching_packages "$@"); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    echo "Start $package_name installation..."
                    . "$installer_dir/.install.sh"
                )
            fi
        done
    fi
}

list_packages()
{
    if [ $# = 0 ]; then
        #Print installed packages
        get_installed_packages
    else
        #Print installed packages based on match
        search_matching_installed_packages "$@"
    fi
}

search_packages()
{
    if [ $# = 0 ]; then
        #Print available packages
        get_packages
    else
        #Print available packages based on match
        search_matching_packages "$@"
    fi
}

uninstall_packages()
{
    #Print usage if arguments are empty
    if [ $# = 0 ]; then
        usage
    else
        #Execute based on package match
        for package in $(search_matching_installed_packages "$@"); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    echo "Start $package_name uninstallation..."
                    . "$installer_dir/.uninstall.sh"
                )
            fi
        done
    fi
}

update_packages()
{
    update_command=true
    if [ $# = 0 ]; then
        #Execute for all installed packages
        for package in $(get_installed_packages); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    . "$installer_dir/.install.sh"
                )
            fi
        done
    else
        #Execute based on installed package match
        for package in $(search_matching_installed_packages "$@"); do
            #Check that script for package exists
            if [ -f "$installer_dir/packages/${package}.sh" ]; then
                (   
                    . "$installer_dir/packages/${package}.sh"
                    . "$installer_dir/.install.sh"
                )
            fi
        done
    fi
}

#Check that there are arguments
if [ $# != 0 ]; then
    #Save first argument
    command="$1"

    #Skip first argument
    shift 1
fi

#Check for flag match
ignore_hash_flag=false
refresh_flag=false
while getopts ":xy" opt; do
    case $opt in
        x) ignore_hash_flag=true ;;
        y) refresh_flag=true ;;
        *) usage ;;
    esac
done

#Skip flags in script arguments
shift "$((OPTIND - 1))"

#Reset getopts automatic variable
OPTIND=1

#Check for command match
case "$command" in
    "clean") clean_cache "$@" ;;
    "download") download_packages "$@" ;;
    "install") install_packages "$@" ;;
    "list") list_packages "$@" ;;
    "search") search_packages "$@" ;;
    "uninstall") uninstall_packages "$@" ;;
    "update") update_packages "$@" ;;
    *) usage ;;
esac
