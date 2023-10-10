#!/bin/bash

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
conn_ip=`hostname -I | awk '{print $1}'`

conn_dev=`ip addr | grep $conn_ip | awk '{print $NF}'`
conn_mac=`ip link show $conn_dev|grep ether|awk {'print $2'}`

# be shure, that the desired interface is really connected
if [ "$conn_mac_should" = "$conn_mac" ]; then
    echo -e "\
[connection]\n\
id=$conn_dev\n\
uuid=`uuidgen`\n\
type=ethernet\n\
autoconnect-priority=-999\n\
interface-name=$conn_dev\n\
timestamp=`date +%s`\n\
\n\
[ethernet]\n\
\n\
[ipv4]\n\
address1=$conn_ip_should/$netmask,$gateway\n\
dns=$dns_nm;\n\
ignore-auto-dns=true\n\
method=manual\n\
\n\
[ipv6]\n\
addr-gen-mode=stable-privacy\n\
method=disabled\n\
\n\
[proxy]"\
    > /target/usr/lib/NetworkManager/system-connections/$conn_dev.nmconnection

    chmod 0600 /target/usr/lib/NetworkManager/system-connections/$conn_dev.nmconnection

    curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hostname
    curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hosts
    printf "Domains=$domain" >> /target/etc/systemd/resolved.conf
else
    echo "found desired interface $con_mac, but it's not the primary connected one!"
fi
