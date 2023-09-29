#!/bin/bash

# set static network for current autoinstall environment

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
conn_ip=`hostname -I`
conn_mac=`ip link show $conn_dev|grep ether|awk {'print $2'}`
conn_dev=`ip addr | grep $conn_ip | awk '{print $NF}'`

# be shure, that the desired interface is really connected
if [ "$conn_mac_should" = "$conn_mac" ]; then
    echo -e "\
network:\n\
  ethernets:
    $conn_dev:\n\
      addresses:\n\
        - $conn_ip_should/$netmask\n\
      nameservers:\n\
        addresses: [$dns]\n\
      routes:\n\
        - to: default\n\
          via: $gateway\n\
  version: 2\n"\
    > /etc/netplan/50-cloud-init.yaml

  netplan apply
else
    echo "found desired interface $con_mac, but it's not the primary connected one!"
fi
