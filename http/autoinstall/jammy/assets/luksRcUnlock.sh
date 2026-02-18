#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

PORT=${1:-2222}

# Determine the encrypted Partition
for d in /dev/*; do
    sudo cryptsetup isLuks $d 2>/dev/null && luksDevice=$(echo $d | sed 's/\/dev\///')
done

curtin in-target --target=/target -- apt-get update
curtin in-target --target=/target -- apt-get install -y cryptsetup dropbear dropbear-initramfs dropbear-bin

copy $exePath/assets/ssh/id_rsa.pub /target/etc/dropbear/initramfs/
copy $exePath/assets/ssh/authorized_keys /target/etc/dropbear/initramfs/

echo 'DROPBEAR_OPTIONS="-p '$PORT'"' >> /etc/dropbear/initramfs/dropbear.conf

curtin in-target --target=/target -- dpkg-reconfigure dropbear-initramfs
curtin in-target --target=/target -- update-initramfs -u