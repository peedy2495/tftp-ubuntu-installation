#!/bin/bash
# you have to run this script directly out of the tftp boot dir!

NEXUS='192.168.123.180:8081'

# Ubuntu releases to prepare for netboot
DISTROS=(
    "jammy"
    "noble"
)

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

TFTP_PATH="../$(dirname -- "${BASH_SOURCE[0]}")"

cd $TFTP_PATH
[ -d tmp ] || mkdir tmp

#if [[ ! -e ./shimx64.efi ]]; then
    apt install --reinstall -d -o=dir::cache=./tmp shim-signed
    PKG=`ls ./tmp/archives/shim-signed_*` 
    sudo dpkg -x $PKG ./tmp/shim-signed
    cp ./tmp/shim-signed/usr/lib/shim/shimx64.efi .
#fi

# get pxelinux package and install reqired files
#if [[ ! -e pxelinux.0 ]]; then
    apt install -d -o=dir::cache=./tmp -y pxelinux
    PKG=`ls ./tmp/archives/pxelinux_*` 
    sudo dpkg -x $PKG ./tmp/pxelinux
    cp ./tmp/pxelinux/usr/lib/PXELINUX/pxelinux.0 .
#fi

# get UEFI grub images (unsigned & signed)
[ -f grubnetx64.efi ] || wget -P ./  http://$NEXUS/repository/ubuntu-archive/dists/jammy/main/uefi/grub2-amd64/current/grubnetx64.efi
[ -f grubnetx64.efi.signed ] || wget -P ./  http://$NEXUS/repository/ubuntu-archive/dists/jammy/main/uefi/grub2-amd64/current/grubnetx64.efi.signed
ln -s grubnetx64.efi.signed grubx64.efi

# get grub relevant files from current OS
#if [[ ! -e ./boot/grub/x86_64-efi ]]; then
    mkdir ./boot/grub/x86_64-efi
    cp /usr/share/grub/unicode.pf2 ./boot/grub/
    cp /usr/lib/grub/i386-pc/{command.lst,crypto.lst,fs.lst,terminal.lst} ./grub/x86_64-efi/
#fi

# get pxelinux package and install reqired files
#if [[ ! -e memtest64.efi ]]; then
    wget https://www.memtest.org/download/v8.00/mt86plus_8.00.binaries.zip -P tmp/
    PKG=`ls ./tmp/mt86plus_*`
    unzip -d ./tmp $PKG
    cp tmp/*_x86_64 ./memtest64.efi
#fi

for DISTRO in "${DISTROS[@]}"; do
    source ./scripts/$DISTRO.inc.sh
done

# cleanup
echo "Cleanup temporary artifacts..."
rm -rf ./tmp
