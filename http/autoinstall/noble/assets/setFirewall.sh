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

if [ -f /mnt/ufw_${host}.sh ]; then
  /mnt/ufw_${host}.sh
else
  /mnt/ufw_default.sh
fi
