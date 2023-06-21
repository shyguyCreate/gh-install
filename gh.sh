#!/bin/sh

program="Github-Cli"

#Add -f (force flag) to script
checkFlag=false
forceFlag=false
refreshFlag=false
while getopts ":cfy" opt; do
  case $opt in
    c) checkFlag=true ;;
    f) forceFlag=true ;;
    y) refreshFlag=true ;;
    *) echo "-c to check available updates"
       echo "-f to force installation"
       echo "-y to refresh github tag" ;;
  esac
done

#Reset getopts automatic variable
OPTIND=1


#Get latest tag_name
if [ ! -f /tmp/tag_name_mesloLGS ] || $refreshFlag || $forceFlag
then
  curl -s https://api.github.com/repos/cli/cli/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > /tmp/tag_name_gh
fi

#Save tag_name to variable
tag_name=$(cat /tmp/tag_name_gh)
#Set the install directory with github tag added to its name
installDir="/opt/gh $tag_name"


#Get the current version of the program
current_version=$(find /opt -maxdepth 1 -type d -name "gh *" -printf '%f' -quit | awk '{print $2}')


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && ! $checkFlag || $forceFlag
then
  #Download binaries
  curl -s https://api.github.com/repos/cli/cli/releases/latest \
  | grep "browser_download_url.*linux_amd64.tar.gz\"" \
  | cut -d \" -f 4 \
  | xargs curl -L -o /tmp/gh.tar.gz

  #Remove contents if already installed
  find /opt -maxdepth 1 -type d -name "gh *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  #Expand tar file to folder
  sudo tar zxf /tmp/gh.tar.gz --strip-components=1 -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/bin/gh"

  #Create symbolic link to bin folder
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$installDir/bin/gh" /usr/local/bin

  #Add completions for bash
  sudo mkdir -p /usr/local/share/bash-completion/completions
  gh completion -s bash | sudo tee /usr/local/share/bash-completion/completions/gh > /dev/null

  #Add completions for zsh
  sudo mkdir -p /usr/local/share/zsh/site-functions
  gh completion -s zsh | sudo tee /usr/local/share/zsh/site-functions/_gh > /dev/null

elif $checkFlag && [ "$tag_name" = "$current_version" ]
then
  echo "Update not found for $program"

elif $checkFlag && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi
