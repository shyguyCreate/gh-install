#!/bin/sh

#< Use font for packages that contain only fonts >#

#Name to identify package
package_name=""

#Specify github repo like this "owner/repo-name"
package_repo=""

#Specify type of package (app|bin|font)
package_type=""

#Regex match for package for all architectures
package_for_any_arch=""

#Hashes are in same filename as download match plus extension
hash_extension=""
#Regex match for filename with hash
hash_file=""
#Specify hash algorithm when not found in extension
hash_algorithm=""

#Remove num of leading folders in tar archive
strip_components=

#Path to fonts based on download (start with ./) (wildcards allowed)
font_name=""
