#!/bin/sh

#Name to identify package
package_name="gh"

#Specify github repo like this 'owner/repo-name'
package_repo="cli/cli"

#Specify type of package (app|bin|font)
package_type="bin"

#Regex match for package for specific architecture
download_x64='gh_.*_linux_amd64\.tar\.gz'
download_arm32='gh_.*_linux_armv6\.tar\.gz'
download_arm64='gh_.*_linux_arm64\.tar\.gz'
download_x32='gh_.*_linux_386\.tar\.gz'

#Regex match for filename with hash
hash_file='gh_.*_checksums.txt'
#Specify hash algorithm when not found in extension
hash_algorithm='sha256'

#Remove num of leading folders in tar archive
strip_components=1

#Path to binary based on download (start with ./)
bin_package="./bin/$package_name"

#Completions for bash/zsh/fish using Cobra completion command (old|new)
cobra_completion="old"
