#!/bin/sh

program="Shellcheck"

#Add flags to script
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
tag_tmp_file="/tmp/tag_name_shellcheck"
if [ ! -f "$tag_tmp_file" ] || [ $refreshFlag = true ] || [ $forceFlag = true ]
then
  curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > "$tag_tmp_file"
fi

#Save tag_name to variable
tag_name=$(cat "$tag_tmp_file")
#Set the install directory with github tag added to its name
installDir="/opt/shellcheck $tag_name"


#Get the current version of the program
current_version=$(find /opt -maxdepth 1 -mindepth 1 -type d -name "shellcheck *" -printf '%f' -quit | awk '{print $2}')


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ $checkFlag = false ] || [ $forceFlag = true ]
then
  echo "Downloading $program"

  #Download binaries
  curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest \
  | grep "browser_download_url.*linux.x86_64.tar.xz\"" \
  | cut -d \" -f 4 \
  | xargs curl -Lf --progress-bar -o /tmp/shellcheck.tar.xz

  #Remove contents if already installed
  find /opt -maxdepth 1 -mindepth 1 -type d -name "shellcheck *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  printf "Begin %s installation..." "$program"

  #Expand tar file to folder
  sudo tar Jxf /tmp/shellcheck.tar.xz --strip-components=1 -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/shellcheck"

  #Create symbolic link to bin folder
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$installDir/shellcheck" /usr/local/bin

  if [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ]
  then
    printf "Finished\n"
  else
    printf "Failed\n"
  fi

elif [ $checkFlag = true ] && [ "$tag_name" = "$current_version" ]
then
  echo "No update found for $program"

elif [ $checkFlag = true ] && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi
