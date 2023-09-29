#!/bin/sh

#Add flags to script
checkFlag=false
forceFlag=false
refreshFlag=false
while getopts ":cfy" opt; do
  case $opt in
    c) checkFlag=true ;;
    f) forceFlag=true ;;
    y) refreshFlag=true ;;
    *)
      echo "-c to check available updates"
      echo "-f to force installation"
      echo "-y to refresh github tag"
      ;;
  esac
done

#Reset getopts automatic variable
OPTIND=1

request_latest_tag()
{
  #File to save the tag_name
  tag_tmp_file="/tmp/tag_name_$program_file"

  #Get latest tag_name from github api
  if [ ! -f "$tag_tmp_file" ] || [ "$refreshFlag" = true ] || [ "$forceFlag" = true ]; then
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
      | grep tag_name \
      | cut -d \" -f 4 \
      | xargs > "$tag_tmp_file"
  fi
}

get_install_dir()
{
  #Save tag_name to variable
  tag_name=$(cat "$tag_tmp_file")
  #Set the install directory with github tag added to its name
  installDir="/opt/$program_file $tag_name"
}

get_current_version()
{
  #Get the current version of the program
  current_version=$(find /opt -maxdepth 1 -mindepth 1 -type d -name "$program_file *" -printf '%f' -quit | awk '{print $2}')
}

downlaod_program()
{
  echo "Downloading $program_name"

  #Download binaries
  curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | grep "\"browser_download_url.*/$download_match\"" \
    | cut -d \" -f 4 \
    | xargs curl -Lf --progress-bar -o "/tmp/$program_tmp_file"
}

uninstall_old_versions()
{
  #Remove contents if already installed
  find /opt -maxdepth 1 -mindepth 1 -type d -name "$program_file *" -exec sudo rm -rf '{}' \+
}

install_program()
{
  #Create folder for contents
  sudo mkdir -p "$installDir"

  printf "Begin %s installation..." "$program_name"

  #Expand tar file to folder
  sudo tar zxf "/tmp/$program_tmp_file" -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/bin/$program_file"

  #Create symbolic link to bin folder
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$installDir/bin/$program_file" /usr/local/bin

  #Add completions for bash
  sudo mkdir -p /usr/local/share/bash-completion/completions
  sudo cp "$installDir/resources/completions/bash/codium" /usr/local/share/bash-completion/completions

  #Add completions for zsh
  sudo mkdir -p /usr/local/share/zsh/site-functions
  sudo cp "$installDir/resources/completions/zsh/_codium" /usr/local/share/zsh/site-functions

  #Copy application image
  sudo mkdir -p /usr/local/share/pixmaps
  sudo cp "$installDir/resources/app/resources/linux/code.png" /usr/local/share/pixmaps/codium.png

  [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"
}

install_logic()
{
  #Start installation if github version is not equal to installed version
  if [ "$tag_name" != "$current_version" ] && [ "$checkFlag" = false ] || [ "$forceFlag" = true ]; then
    downlaod_program
    install_program
    uninstall_old_versions

  elif [ "$checkFlag" = true ] && [ "$tag_name" = "$current_version" ]; then
    echo "No update found for $program_name"

  elif [ "$checkFlag" = true ] && [ "$tag_name" != "$current_version" ]; then
    echo "Update found for $program_name"

  else
    echo "$program_name is up to date"
  fi
}
