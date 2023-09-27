#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"

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
installDir="/usr/local/share/fonts/$program_file $tag_name"

#Get the current version that is appended inside the folder name
current_version=$(find /usr/local/share -maxdepth 2 -mindepth 2 -type d -path "/usr/local/share/fonts/$program_file *" -printf '%f' -quit | awk '{print $2}')

#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ $checkFlag = false ] || [ $forceFlag = true ]; then
  echo "Downloading $program_name"

  #Download fonts
  curl -Lf --progress-bar "https://github.com/$repo/releases/latest/download/Meslo.zip" -o "/tmp/$program_file.zip"

  #Remove fonts folder and older fonts if exist
  rm -rf "/tmp/$program_file"
  find /usr/local/share -maxdepth 2 -mindepth 2 -type d -path "/usr/local/share/fonts/$program_file *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  printf "Begin %s installation..." "$program_name"

  #Extract fonts
  mkdir -p "/tmp/$program_file"
  unzip -q "/tmp/$program_file.zip" -d "/tmp/$program_file"

  #Install fonts globally
  sudo cp "/tmp/$program_file"/MesloLGSNerdFont-*.ttf "$installDir"

  [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"

elif [ $checkFlag = true ] && [ "$tag_name" = "$current_version" ]; then
  echo "No update found for $program_name"

elif [ $checkFlag = true ] && [ "$tag_name" != "$current_version" ]; then
  echo "Update found for $program_name"

else
  echo "$program_name is up to date"
fi
