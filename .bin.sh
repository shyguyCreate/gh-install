#!/bin/sh

bash_completion_dir="/usr/local/share/bash-completion/completions"
zsh_completion_dir="/usr/local/share/zsh/site-functions"
fish_completion_dir="/usr/local/share/fish/vendor_completions.d"
image_dir="/usr/local/share/pixmaps"

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
    image_name="$1"
    image_dir="$2"
    sudo mkdir -p "$image_dir"
    sudo cp "$image_dir" "$image_dir/$image_name"
}

add_internet_image()
{
    #Add application image file
    image_name="$1"
    url="$2"
    sudo mkdir -p "$image_dir"
    sudo curl -s "$url" -o "$image_dir/$image_name"
}

add_old_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p "$bash_completion_dir"
    eval "$program_file completion -s bash | sudo tee "$bash_completion_dir"/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p "$zsh_completion_dir"
    eval "$program_file completion -s zsh | sudo tee "$zsh_completion_dir"/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p "$fish_completion_dir"
    eval "$program_file completion -s fish | sudo tee "$fish_completion_dir"/$program_file.fish > /dev/null"
}

add_new_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p "$bash_completion_dir"
    eval "$program_file completion bash | sudo tee "$bash_completion_dir"/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p "$zsh_completion_dir"
    eval "$program_file completion zsh | sudo tee "$zsh_completion_dir"/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p "$fish_completion_dir"
    eval "$program_file completion fish | sudo tee "$fish_completion_dir"/$program_file.fish > /dev/null"
}

add_desktop_file()
{
    #Add application .desktop file
    sudo mkdir -p "$(dirname "$program_desktop_file")"
    echo "$desktop_file_content" | sudo tee "$program_desktop_file" > /dev/null
}

change_program_permission()
{
    #Change execute permissions
    sudo chmod +x "$bin_program"
}

install_program()
{
    printf "Begin %s installation..." "$program_name"

    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$bin_program" /usr/local/bin

    [ -f "/usr/local/bin/$program_file" ] && printf "Finished\n" || printf "Failed\n"
}
