#!/bin/sh

type="bin"
type="font"

script_variables()
{
    tag_tmp_file="dir to tag file in tmp"
    online_tag="tag of repo"
    installDir="intall dir with name and tag"
    current_version="version intalled"

}

program_name="NAME"
program_file="name"
repo="owner/repo"
installDir="root install dir"

download_match='regex match'
download_file='literal file name'
program_tmp_file="dir to download"

#Source file with functions
. "$(dirname "$0")/.install.sh"

bin_program="installDir with file name"
bin_install_dir="installDir with file name"
font_install_dir="installDir with file name"

#Install and uninstall
mkdir -p "/tmp/$program_file"
extract_tar_gz ""
extract_tar_xz ""
install_font "/tmp/$program_file" "MesloLGSNerdFont-*.ttf"
uninstall_old_version
