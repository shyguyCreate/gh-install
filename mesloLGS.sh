#!/bin/sh

#Add -f (force flag) to script
forceFlag=false
while getopts ":f" opt; do
  case $opt in
    f) forceFlag=true ;;
    *) echo "Use -f to force installation" ;;
  esac
done

#Reset getopts automatic variable
OPTIND=1


#Get latest tag_name
if $forceFlag || [ ! -f /tmp/tag_name_mesloLGS ]
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
if $forceFlag || [ "$tag_name" != "$current_version" ]
then
  #Download Meslo Nerd Fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O /tmp/Meslo.zip

  #Remove fonts folder and older fonts if exist
  sudo rm -rf /tmp/Meslo /usr/share/fonts/mesloLGS\ *

  #Extract fonts
  mkdir -p /tmp/Meslo
  unzip -q /tmp/Meslo.zip -d /tmp/Meslo

  #Install fonts globally and add version inside the folder name
  sudo mkdir -p "$installDir"
  sudo cp /tmp/Meslo/MesloLGSNerdFont-*.ttf "$installDir"
else
  echo "Meslo Nerd Fonts are up to date."
fi
