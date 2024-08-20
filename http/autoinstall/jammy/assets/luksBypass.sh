#!/bin/bash

# luksByPass creates a keyfile based autodecryption for automatic deployments.
# It has to be removed after a successfull rollout like:
#   - cryptsetup luksRemoveKey /dev/<luksDevice> /<filePath>/keyfile
#   - remove entries in /etc/crypttab and /etc/cryptsetup-initramfs/conf-hook
#   - delete the keyfile
#   - update initramfs

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

passwd="$1"
luksDevice="vda3"
keyFilePath="/boot/keyfile"

# create a random keyfile
dd if=/dev/urandom of=/target$keyFilePath bs=1024 count=4
chmod 0600 /target$keyFilePath

# add the keyfile to luks
echo "ChangeMe" | cryptsetup luksAddKey --force-password /dev/$luksDevice /target$keyFilePath >>/target/root/debug.txt

# preparing for using the kefile in initramfs
echo "KEYFILE_PATTERN=$keyFilePath" >> /target/etc/cryptsetup-initramfs/conf-hook
sed -i "s|none|${keyFilePath}|g" /target/etc/crypttab

# bake nwe initramfs
curtin in-target --target=/target -- update-initramfs -u