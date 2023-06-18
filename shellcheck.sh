#!/bin/sh

#Add -f (force flag) to script
forceFlag=false
refreshFlag=false
while getopts ":fy" opt; do
  case $opt in
    f) forceFlag=true ;;
    y) refreshFlag=true ;;
    *) echo "-f to force installation"
       echo "-y to refresh github tag" ;;
  esac
done

#Reset getopts automatic variable
OPTIND=1


#Get latest tag_name
if [ ! -f /tmp/tag_name_mesloLGS ] || $refreshFlag || $forceFlag
then
  curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > /tmp/tag_name_shellcheck
fi

#Save tag_name to variable
tag_name=$(cat /tmp/tag_name_shellcheck)
#Set the install directory with github tag added to its name
installDir="/opt/shellcheck $tag_name"


#Get the current version of the program
unset current_version; if [ -n "$(ls -d /opt/shellcheck\ *)" ]
then
  current_version=$(basename /opt/shellcheck\ * | awk '{print $2}')
fi


#Start installation if github version is not equal to installed version
if $forceFlag || [ "$tag_name" != "$current_version" ]
then
  #Download binaries
  curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest \
  | grep "browser_download_url.*linux.x86_64.tar.xz\"" \
  | cut -d \" -f 4 \
  | xargs curl -L -o /tmp/shellcheck.tar.xz

  #Remove contents if already installed
  sudo rm -rf /opt/shellcheck\ *

  #Create folder for contents
  sudo mkdir -p "$installDir"

  #Expand tar file to folder
  sudo tar Jxf /tmp/shellcheck.tar.xz --strip-components=1 -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/shellcheck"

  #Create symbolic link to bin folder
  sudo ln -sf "$installDir/shellcheck" /usr/bin
else
  echo "Shellcheck is up to date."
fi
