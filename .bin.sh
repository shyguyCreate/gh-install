#!/bin/sh

add_bash_completion()
{
    #Add completions for bash
    completion_file="$1"
    sudo mkdir -p /usr/local/share/bash-completion/completions
    sudo cp "$completion_file" /usr/local/share/bash-completion/completions
}

add_zsh_completion()
{
    #Add completions for zsh
    completion_file="$1"
    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo cp "$completion_file" /usr/local/share/zsh/site-functions
}

add_fish_completion()
{
    #Add completions for fish
    completion_file="$1"
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    sudo cp "$completion_file" /usr/local/share/fish/vendor_completions.d
}

add_image()
{
    #Add application image file
    image_file="$1"
    sudo mkdir -p /usr/local/share/pixmaps
    sudo cp "$image_file" /usr/local/share/pixmaps
}

add_internet_image()
{
    #Add application image file
    url="$1"
    sudo mkdir -p "$(dirname "$program_image_file")"
    sudo curl -s "$url" -o "$program_image_file"
}

add_old_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    eval "$program_file completion -s bash | sudo tee /usr/local/share/bash-completion/completions/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    eval "$program_file completion -s zsh | sudo tee /usr/local/share/zsh/site-functions/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    eval "$program_file completion -s fish | sudo tee /usr/local/share/fish/vendor_completions.d/$program_file.fish > /dev/null"
}

add_new_Cobra_completions()
{
    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    eval "$program_file completion bash | sudo tee /usr/local/share/bash-completion/completions/$program_file > /dev/null"

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    eval "$program_file completion zsh | sudo tee /usr/local/share/zsh/site-functions/_$program_file > /dev/null"

    #Add completions for fish
    sudo mkdir -p /usr/local/share/fish/vendor_completions.d
    eval "$program_file completion fish | sudo tee /usr/local/share/fish/vendor_completions.d/$program_file.fish > /dev/null"
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
