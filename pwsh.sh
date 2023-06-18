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
unset current_version; if [ -n "$(ls -d /opt/pwsh\ *)" ]
then
  current_version=$(basename /opt/pwsh\ * | awk '{print $2}')
fi


#Start installation if github version is not equal to installed version
if $forceFlag || [ "$tag_name" != "$current_version" ]
then
  #Download binaries
  curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest \
  | grep "browser_download_url.*linux-x64.tar.gz\"" \
  | cut -d \" -f 4 \
  | xargs curl -L -o /tmp/pwsh.tar.gz

  #Remove contents if already installed
  sudo rm -rf /opt/pwsh\ *

  #Create folder for contents
  sudo mkdir -p "$installDir"

  #Expand tar file to folder
  sudo tar zxf /tmp/pwsh.tar.gz -C "$installDir"

  #Change execute permissions
  sudo chmod +x "$installDir/pwsh"

  #Create symbolic link to bin folder
  sudo ln -sf "$installDir/pwsh" /usr/bin
else
  echo "Powershell is up to date."
fi


#Check if .desktop file exist
if $forceFlag || [ ! -f /usr/share/applications/pwsh.desktop ]
then
  #Copy application image
  sudo mkdir -p /usr/share/pixmaps
  sudo curl -s https://raw.githubusercontent.com/PowerShell/PowerShell-Snap/master/stable/assets/icon.png -o /usr/share/pixmaps/pwsh.png

  #Write application .desktop file
  sudo mkdir -p /usr/share/applications
  echo \
  '[Desktop Entry]
  Name=Powershell
  Comment=Powershell Core
  GenericName=Powershell
  Exec=/usr/bin/pwsh
  Icon=/usr/share/pixmaps/pwsh.png
  Categories=Utility;Development;Shell
  Type=Application
  Terminal=true' \
  | sed 's/^[ \t]*//' - | sudo tee /usr/share/applications/pwsh.desktop > /dev/null
fi
