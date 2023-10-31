#!/bin/sh

#### Section 1 ####

download_from_match()
{
    #Download program with regex match
    echo "Downloading $program_name"
    download_match="$1"
    url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
            | grep "\"browser_download_url.*/$download_match\"" \
            | cut -d \" -f 4)
    #Save dir to save download with the extension get from the program in the url
    download_file="${url##*/}"
    program_tmp_file="/tmp/$download_file"
    curl -Lf --progress-bar "$url" -o "$program_tmp_file"
}

download_from_literal()
{
    #Download program with literal name
    echo "Downloading $program_name"
    #Save dir to save download with the extension get from the program in the url
    download_file="$1"
    program_tmp_file="/tmp/$download_file"
    curl -Lf --progress-bar "https://github.com/$repo/releases/latest/download/$download_file" -o "$program_tmp_file"
}

#### Section 2 ####

#Set the extract directory with github tag added to its name
extractDir="/tmp/${program_file}-${online_tag}"

extract_tar_gz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$extractDir"
    eval "sudo tar zxf $program_tmp_file -C $extractDir $1"
}

extract_tar_xz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$extractDir"
    eval "sudo tar Jxf $program_tmp_file -C $extractDir $1"
}

#### Section 3 ####

copy_to_install_dir()
{
    sudo mkdir -p "$installDir"
    if [ -d "$extractDir" ] && [ -n "$(ls "$extractDir")" ]; then
        #Copy files extracted to folder installation
        sudo cp -r "$extractDir"/* "$installDir"
    else
        #Copy program file to folder installation
        sudo cp "$program_tmp_file" "$installDir"
    fi
}

#### Section 4 ####

install_bin()
{
    #Change execute permissions
    bin_program="$1"
    sudo chmod +x "$bin_program"

    #Create symbolic link to bin folder
    bin_directory="/usr/local/bin"
    sudo mkdir -p "$bin_directory"
    sudo ln -sf "$bin_program" "$bin_directory"
}

install_font()
{
    #If no parameter pass, set wildcard to match all files
    font_name="${1:-*}"
    #Copy fonts to install directory
    find "$extractDir" -maxdepth 1 -mindepth 1 -type f -name "$font_name" -exec sudo cp '{}' "$installDir" \;
}

#### Section 5 ####

uninstall_old_version()
{
    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+
}

#### Section 6 ####

bash_completion_dir="/usr/local/share/bash-completion/completions"
zsh_completion_dir="/usr/local/share/zsh/site-functions"
fish_completion_dir="/usr/local/share/fish/vendor_completions.d"

add_bash_completion()
{
    #Add completions for bash
    completion_file="$1"
    sudo mkdir -p "$bash_completion_dir"
    sudo cp "$completion_file" "$bash_completion_dir"
}

add_zsh_completion()
{
    #Add completions for zsh
    completion_file="$1"
    sudo mkdir -p "$zsh_completion_dir"
    sudo cp "$completion_file" "$zsh_completion_dir"
}

add_fish_completion()
{
    #Add completions for fish
    completion_file="$1"
    sudo mkdir -p "$fish_completion_dir"
    sudo cp "$completion_file" "$fish_completion_dir"
}

add_old_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p "$bash_completion_dir"
    eval "$program_file completion -s bash | sudo tee $bash_completion_dir/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p "$zsh_completion_dir"
    eval "$program_file completion -s zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p "$fish_completion_dir"
    eval "$program_file completion -s fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
}

add_new_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p "$bash_completion_dir"
    eval "$program_file completion bash | sudo tee $bash_completion_dir/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p "$zsh_completion_dir"
    eval "$program_file completion zsh | sudo tee $zsh_completion_dir/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p "$fish_completion_dir"
    eval "$program_file completion fish | sudo tee $fish_completion_dir/$program_file.fish > /dev/null"
}

#### Section 7 ####

image_dir="/usr/local/share/pixmaps"

add_local_image()
{
    #Check if pixmaps image file exist
    if [ -f "$image_dir/$image_name" ] && [ $forceFlag = false ]; then
        return
    fi
    #Get extension of image parameter
    image_name="${program_file}.${1##*.}"
    #Add application image file
    local_image_dir="$1"
    sudo mkdir -p "$image_dir"
    sudo cp "$local_image_dir" "$image_dir/$image_name"
}

add_internet_image()
{
    #Check if pixmaps image file exist
    if [ -f "$image_dir/$image_name" ] && [ $forceFlag = false ]; then
        return
    fi
    #Get extension of image parameter
    image_name="${program_file}.${1##*.}"
    #Add application image file
    url="$1"
    sudo mkdir -p "$image_dir"
    sudo curl -s "$url" -o "$image_dir/$image_name"
}

#### Section 8 ####

desktop_file="/usr/local/share/applications/$program_file.desktop"

add_desktop_file()
{
    #Check if .desktop file exist
    if [ -f "$desktop_file" ] && [ $forceFlag = false ]; then
        return
    fi
    #Add application .desktop file
    sudo mkdir -p "$(dirname "$desktop_file")"
    echo \
        "[Desktop Entry]
        Type=Application
        Name=$program_name
        GenericName=$program_name
        Exec="$bin_directory"/$program_file
        Icon=$image_dir/$image_name
        Categories=Utility;Development
        Terminal=$1" \
        | sed 's/^[ \t]*//' - \
        | sudo tee "$desktop_file" > /dev/null
}
