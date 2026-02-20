#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

PORT=${1:-2222}

cidr_to_netmask() {
    local cidr=$1
    local netmask_octets=""
    local full_octets=$((cidr / 8))
    local partial_octet=$((cidr % 8))

    for ((i=0; i<4; i++)); do
        if [ $i -lt $full_octets ]; then
            netmask_octets+="255"
        elif [ $i -eq $full_octets ]; then
            netmask_octets+=$(( 256 - (2**(8-partial_octet)) ))
        else
            netmask_octets+="0"
        fi
        [ $i -lt 3 ] && netmask_octets+="."
    done
    echo $netmask_octets
}

curtin in-target --target=/target -- apt-get update
curtin in-target --target=/target -- apt-get install -y cryptsetup dropbear dropbear-initramfs dropbear-bin

cp $exePath/ssh/id_*.pub /target/etc/dropbear/initramfs/
cp $exePath/ssh/authorized_keys /target/etc/dropbear/initramfs/

# Set up the network for the initramfs environment
source $exePath/hostValues
for host in "${!hosts[@]}"; do
    if ip addr | grep -q "${hosts[$host]}"; then
        break
    fi
done

ip=${IPs[$host]}
device=$(ip addr|grep 'state UP'| cut -d ':' -f2 | xargs)
sed -i "/DEVICE=/a IP=$ip::$gateway:$(cidr_to_netmask $netmask)::$device:off\n" /target/etc/initramfs-tools/initramfs.conf

# Set the dropbear port for the initramfs environment
echo 'DROPBEAR_OPTIONS="-p '$PORT'"' >> /target/etc/dropbear/initramfs/dropbear.conf

# Reconfigure dropbear and update the initramfs
curtin in-target --target=/target -- dpkg-reconfigure dropbear-initramfs
curtin in-target --target=/target -- update-initramfs -u