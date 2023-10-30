#!/bin/sh

downlaod_program()
{
    #Check if program is already downloaded
    if [ ! -f "$program_tmp_file" ] || [ "$forceFlag" = true ]; then
        echo "Downloading $program_name"

        if [ -n "$download_match" ]; then
            #Download binaries
            curl -s "https://api.github.com/repos/$repo/releases/latest" \
                | grep "\"browser_download_url.*/$download_match\"" \
                | cut -d \" -f 4 \
                | xargs curl -Lf --progress-bar -o "$program_tmp_file"
        elif [ -n "$download_file" ]; then
            curl -Lf --progress-bar "https://github.com/$repo/releases/latest/download/$download_file" -o "$program_tmp_file"
        else
            echo "Download match or file not specified"
        fi
    fi
}

extract_tar_gz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$installDir"
    eval "sudo tar zxf $program_tmp_file -C $installDir $1"
}

extract_tar_xz()
{
    #Expand tar file to folder installation
    sudo mkdir -p "$installDir"
    eval "sudo tar Jxf $program_tmp_file -C $installDir $1"
}

copy_program()
{
    #Copy program file to folder installation
    sudo mkdir -p "$installDir"
    sudo cp "$program_tmp_file" "$installDir"
}

bash_completion_dir="/usr/local/share/bash-completion/completions"
zsh_completion_dir="/usr/local/share/zsh/site-functions"
fish_completion_dir="/usr/local/share/fish/vendor_completions.d"
image_dir="/usr/local/share/pixmaps"
desktop_file="/usr/local/share/applications/$program_file.desktop"

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

add_local_image()
{
    #Add application image file
    local_image_dir="$2"
    sudo mkdir -p "$image_dir"
    sudo cp "$local_image_dir" "$image_dir/$image_name"
}

add_internet_image()
{
    #Check if pixmaps image file exist
    if [ ! -f "$image_dir/$image_name" ] || [ $forceFlag = true ]; then
        #Add application image file
        url="$1"
        sudo mkdir -p "$image_dir"
        sudo curl -s "$url" -o "$image_dir/$image_name"
    fi
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

add_desktop_file()
{
    #Check if .desktop file exist
    if [ ! -f "$desktop_file" ] || [ $forceFlag = true ]; then
        #Add application .desktop file
        sudo mkdir -p "$(dirname "$desktop_file")"
        desktop_file_content=$(
            cat << EOF
[Desktop Entry]
Type=Application
Name=$program_name
GenericName=$program_name
Exec=/usr/local/bin/$program_file
Icon=$image_dir/$image_name
Categories=Utility;Development
Terminal=$1
EOF
        )
        echo "$desktop_file_content" | sudo tee "$desktop_file" > /dev/null
    fi
}

change_bin_permissions()
{
    #Change execute permissions
    sudo chmod +x "$bin_program"
}

install_program()
{
    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$bin_program" /usr/local/bin
}

install_font()
{
    #Install fonts globally
    find "$1" -maxdepth 1 -mindepth 1 -type f -name "$2" -exec sudo cp '{}' "$installDir" \;
}

uninstall_old_version()
{
    #Remove contents if already installed
    find "$(dirname "$installDir")" -maxdepth 1 -mindepth 1 -type d -name "${program_file}-*" -not -path "$installDir" -exec sudo rm -rf '{}' \+
}
