#!/bin/bash
# you have to run this script directly out of the tftp boot dir!

NEXUS='192.168.123.180:8081'

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

TFTP_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

cd $TFTP_PATH
[ -d tmp ] || mkdir tmp

# get syslinix package and install reqired files
if [[ ! -e ./syslinux ]]; then
    apt install -d -o=dir::cache=./tmp syslinux-common
    PKG=`ls ./tmp/archives/syslinux-common_*` 
    sudo dpkg -x $PKG ./tmp/syslinux-common
    
    mkdir -p ./syslinux/bios
    cp ./tmp/syslinux-common/usr/lib/syslinux/modules/bios/{ldlinux.c32,libutil.c32,menu.c32} ./syslinux/bios/

    ln -s syslinux/bios/ldlinux.c32 ldlinux.c32
    ln -s syslinux/bios/libutil.c32 libutil.c32
    ln -s syslinux/bios/menu.c32 menu.c32
fi

if [[ ! -e ./shimx64.efi ]]; then
    apt install -d -o=dir::cache=./tmp shim-signed
    PKG=`ls ./tmp/archives/shim-signed_*` 
    sudo dpkg -x $PKG ./tmp/shim-signed
    cp ./tmp/shim-signed/usr/lib/shim/shimx64.efi .
fi

# get pxelinux package and install reqired files
if [[ ! -e pxelinux.0 ]]; then
    apt install -d -o=dir::cache=./tmp -y pxelinux
    PKG=`ls ./tmp/archives/pxelinux_*` 
    sudo dpkg -x $PKG ./tmp/pxelinux
    cp ./tmp/pxelinux/usr/lib/PXELINUX/pxelinux.0 .
fi

# get UEFI grub images (unsigned & signed)
[ -f grubnetx64.efi ] || wget -P ./  http://$NEXUS/repository/ubuntu-archive/dists/jammy/main/uefi/grub2-amd64/current/grubnetx64.efi
[ -f grubnetx64.efi.signed ] || wget -P ./  http://$NEXUS/repository/ubuntu-archive/dists/jammy/main/uefi/grub2-amd64/current/grubnetx64.efi.signed
ln -s grubnetx64.efi.signed grubx64.efi

# get grub relevant files from current OS
if [[ ! -e ./boot/grub/x86_64-efi ]]; then
    mkdir ./boot/grub/x86_64-efi
    cp /usr/share/grub/unicode.pf2 ./boot/grub/
    cp /usr/lib/grub/i386-pc/{command.lst,crypto.lst,fs.lst,terminal.lst} ./boot/grub/x86_64-efi/
fi

if [[ ! -e ./tmp ]]; then
    mkdir ./tmp
fi

# prepare Ubuntu Jammy for netboot
OS_IMAGE=ubuntu-22.04.4-live-server-amd64.iso
if [[ ! -e boot/jammy ]]; then
    mkdir ./boot/jammy
    wget -nc -P ./tmp  http://$NEXUS/repository/ubuntu-releases/22.04/$OS_IMAGE
    mount ./tmp/$OS_IMAGE /mnt
    cp /mnt/casper/{vmlinuz,initrd} boot/jammy/
    umount /mnt
fi

if [[ ! -e memtest64.efi ]]; then
   wget -P ./tmp http://$NEXUS/repository/memtest//v7.00/mt86plus_7.00.binaries.zip
   unzip -d . ./tmp/mt86plus_7.00.binaries.zip
   chmod go+r memtest*
fi

# cleanup
rm -rf ./tmp
