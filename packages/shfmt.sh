#!/bin/sh

#Name to identify package
package_name="shfmt"

#Specify github repo like this "owner/repo-name"
package_repo="mvdan/sh"

#Specify type of package (app|bin|font)
package_type="bin"

#Regex match for package for specific architecture
package_for_x64="shfmt_.*_linux_amd64"
package_for_arm64="shfmt_.*_linux_arm64"
package_for_arm32="shfmt_.*_linux_arm"
package_for_x32="shfmt_.*_linux_386"

#Path to binary based on download (start with ./)
bin_package="./$package_name"
