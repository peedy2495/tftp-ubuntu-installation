#!/bin/bash

# set static network via netplan

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/hostValues

echo $hosts
for host in "${!hosts[@]}"; do
    if ip addr | grep -q "${hosts[$host]}"; then
        break
    fi
done

conn_mac_should=${hosts[$host]}
conn_ip_should=${IPs[$host]}
conn_ip=`hostname -I | cut -d' ' -f1`
conn_dev=`ip addr | grep $conn_ip | awk '{print $NF}'`
conn_mac=`ip link show $conn_dev|grep ether|awk {'print $2'}`

# be shure, that the desired interface is really connected
if [ "$conn_mac_should" = "$conn_mac" ]; then
    echo -e "\
network:\n\
  ethernets:\n\
    ${conn_dev}:\n\
      dhcp4: false
      addresses:\n\
        - ${conn_ip_should}/${netmask}\n\
      nameservers:\n\
        addresses: [${dns}]\n\
      routes:\n\
        - to: default\n\
          via: ${gateway}\n\
  version: 2\n"\
    > /target/etc/cloud/cloud.cfg.d/98-network.cfg

    curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hostname
    curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hosts
    printf "Domains=$domain" >> /target/etc/systemd/resolved.conf
    curtin in-target --target=/target -- systemctl disable systemd-networkd-wait-online.service
    curtin in-target --target=/target -- systemctl mask systemd-networkd-wait-online.service

else
    echo "found desired interface $con_mac, but it's not the primary connected one!"
fi
