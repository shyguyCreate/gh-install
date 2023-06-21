#!/bin/sh

program="Powershell"

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
  curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > /tmp/tag_name_pwsh
fi

#Save tag_name to variable
tag_name=$(cat /tmp/tag_name_pwsh)
#Set the install directory with github tag added to its name
installDir="/opt/pwsh $tag_name"


#Get the current version of the program
current_version=$(find /opt -maxdepth 1 -type d -name "pwsh *" -printf '%f' -quit | awk '{print $2}')


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && ! $checkFlag || $forceFlag
then
  #Download binaries
  curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest \
  | grep "browser_download_url.*linux-x64.tar.gz\"" \
  | cut -d \" -f 4 \
  | xargs curl -L -o /tmp/pwsh.tar.gz

  #Remove contents if already installed
  find /opt -maxdepth 1 -type d -name "pwsh *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  #Expand tar file to folder
  sudo tar zxf /tmp/pwsh.tar.gz -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/pwsh"

  #Create symbolic link to bin folder
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$installDir/pwsh" /usr/local/bin

elif $checkFlag && [ "$tag_name" = "$current_version" ]
then
  echo "Update not found for $program"

elif $checkFlag && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi


#Check if .png file exist
if [ ! -f /usr/local/share/pixmaps/pwsh.png ] && ! $checkFlag || $forceFlag
then
  #Copy application image
  sudo mkdir -p /usr/local/share/pixmaps
  sudo curl -s https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png -o /usr/local/share/pixmaps/pwsh.png
fi


#Check if .desktop file exist
if [ ! -f /usr/local/share/applications/pwsh.desktop ] && ! $checkFlag || $forceFlag
then
  #Write application .desktop file
  sudo mkdir -p /usr/local/share/applications
  echo \
  '[Desktop Entry]
  Name=Powershell
  Comment=Powershell Core
  GenericName=Powershell
  Exec=/usr/local/bin/pwsh
  Icon=/usr/local/share/pixmaps/pwsh.png
  Categories=Utility;Development;Shell
  Type=Application
  Terminal=true' \
  | sed 's/^[ \t]*//' - | sudo tee /usr/local/share/applications/pwsh.desktop > /dev/null
fi
