#!/bin/sh

#Source file with functions
. "$(dirname "$0")/.install.sh"

test()
{
    if [ $forceFlag = true ]; then
        echo "hello"
    fi
    get_install_dir "hello" "2.64"
    echo $installDir
}

program_file="$1"
repo="$2"

request_latest_tag

get_current_version

program_name="$1"
download_match="$1"
program_tmp_file="$1"

install_logic
