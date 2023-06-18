#!/bin/sh

program="Meslo Nerd Fonts"

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
  curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > /tmp/tag_name_mesloLGS
fi

#Save tag_name to variable
tag_name=$(cat /tmp/tag_name_mesloLGS)
#Set the install directory with github tag added to its name
installDir="/usr/share/fonts/mesloLGS $tag_name"


#Get the current version that is appended inside the folder name
unset current_version; if [ -n "$(ls -d /usr/share/fonts/mesloLGS\ *)" ]
then
  current_version=$(basename /usr/share/fonts/mesloLGS\ * | awk '{print $2}')
fi


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && ! $checkFlag || $forceFlag
then
  #Download fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O /tmp/Meslo.zip

  #Remove fonts folder and older fonts if exist
  sudo rm -rf /tmp/Meslo /usr/share/fonts/mesloLGS\ *

  #Extract fonts
  mkdir -p /tmp/Meslo
  unzip -q /tmp/Meslo.zip -d /tmp/Meslo

  #Install fonts globally
  sudo mkdir -p "$installDir"
  sudo cp /tmp/Meslo/MesloLGSNerdFont-*.ttf "$installDir"

elif $checkFlag && [ "$tag_name" = "$current_version" ]
then
  echo "Update not found for $program"

elif $checkFlag && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi
