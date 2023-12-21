#!/bin/sh

#Name to identify package
package_name="mesloLGS"

#Specify github repo like this "owner/repo-name"
package_repo="ryanoasis/nerd-fonts"

#Specify type of package (app|bin|font)
package_type="font"

#Regex match for package for all architectures
package_for_any_arch="Meslo\.tar\.xz"

#Path to fonts based on download (start with ./) (wildcards allowed)
font_name="MesloLGSNerdFont-*.ttf"
