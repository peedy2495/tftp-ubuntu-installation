#!/bin/bash

# luksByPass creates a keyfile based autodecryption for automatic deployments.
# It has to be removed after a successfull rollout like:
#   - cryptsetup luksRemoveKey /dev/<luksDevice> /<filePath>/keyfile
#   - remove entries in /etc/crypttab and /etc/cryptsetup-initramfs/conf-hook
#   - delete the keyfile
#   - update initramfs

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

passwd="$1"
keyFilePath="/boot/keyfile"

# Determine the encrypted Partition
for d in /dev/*; do
    sudo cryptsetup isLuks $d 2>/dev/null && luksDevice=$(echo $d | sed 's/\/dev\///')
done

# Create a random keyfile
dd if=/dev/urandom of=/target$keyFilePath bs=1024 count=4
chmod 0600 /target$keyFilePath

# Add the keyfile to luks
echo "ChangeMe" | cryptsetup luksAddKey --force-password /dev/$luksDevice /target$keyFilePath >>/target/root/debug.txt

# Preparing for using the kefile in initramfs
echo "KEYFILE_PATTERN=$keyFilePath" >> /target/etc/cryptsetup-initramfs/conf-hook
sed -i "s|none|${keyFilePath}|g" /target/etc/crypttab

# Bake nwe initramfs
curtin in-target --target=/target -- update-initramfs -u