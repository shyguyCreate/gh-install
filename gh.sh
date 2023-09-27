#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"

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

#Get latest tag_name
tag_tmp_file="/tmp/tag_name_$program_file"
if [ ! -f "$tag_tmp_file" ] || [ $refreshFlag = true ] || [ $forceFlag = true ]; then
  curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | grep tag_name \
    | cut -d \" -f 4 \
    | xargs > "$tag_tmp_file"
fi

#Save tag_name to variable
tag_name=$(cat "$tag_tmp_file")
#Set the install directory with github tag added to its name
installDir="/opt/$program_file $tag_name"

#Get the current version of the program
current_version=$(find /opt -maxdepth 1 -mindepth 1 -type d -name "$program_file *" -printf '%f' -quit | awk '{print $2}')

#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ $checkFlag = false ] || [ $forceFlag = true ]; then
  echo "Downloading $program_name"

  #Download binaries
  curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | grep "\"browser_download_url.*/gh_.*_linux_amd64\.tar\.gz\"" \
    | cut -d \" -f 4 \
    | xargs curl -Lf --progress-bar -o "/tmp/$program_file.tar.gz"

  #Remove contents if already installed
  find /opt -maxdepth 1 -mindepth 1 -type d -name "$program_file *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  printf "Begin %s installation..." "$program_name"

  #Expand tar file to folder
  sudo tar zxf "/tmp/$program_file.tar.gz" --strip-components=1 -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/bin/$program_file"

  #Create symbolic link to bin folder
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$installDir/bin/$program_file" /usr/local/bin

  #Add completions for bash
  sudo mkdir -p /usr/local/share/bash-completion/completions
  gh completion -s bash | sudo tee /usr/local/share/bash-completion/completions/gh > /dev/null

  #Add completions for zsh
  sudo mkdir -p /usr/local/share/zsh/site-functions
  gh completion -s zsh | sudo tee /usr/local/share/zsh/site-functions/_gh > /dev/null

  #Add completions for fish
  sudo mkdir -p /usr/local/share/fish/vendor_completions.d
  gh completion -s fish | sudo tee /usr/local/share/fish/vendor_completions.d/gh.fish > /dev/null

  [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"

elif [ $checkFlag = true ] && [ "$tag_name" = "$current_version" ]; then
  echo "No update found for $program_name"

elif [ $checkFlag = true ] && [ "$tag_name" != "$current_version" ]; then
  echo "Update found for $program_name"

else
  echo "$program_name is up to date"
fi
