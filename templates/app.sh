#!/bin/sh

#< Use app for packages that come bundle with libraries and dependencies >#

#Name to identify package
package_name=""

#Specify github repo like this "owner/repo-name"
package_repo=""

#Specify type of package (app|bin|font)
package_type=""

#Regex match for package for specific architecture
package_for_x64=""
package_for_arm64=""
package_for_arm32=""
package_for_x32=""

#Hashes are in same filename as download match plus extension
hash_extension=""
#Regex match for filename with hash
hash_file=""
#Specify hash algorithm when not found in extension
hash_algorithm=""

#Remove num of leading folders in tar archive
strip_components=

#Path to binary based on download (start with ./)
bin_package=""

#Path to completion file based on download (start with ./)
bash_completion=""
zsh_completion=""
fish_completion=""
#Completions for bash/zsh/fish using Cobra completion command (old|new)
cobra_completion=""

#Path to image file based on download (start with ./)
local_desktop_image=""
#Online url for application image
online_desktop_image=""
#Should package be started in terminal (true|false)
is_terminal=
