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
  # Drop the ufw rules for future modification
  sed 's/^curtin in-target --target=\/target -- //' /mnt/ufw_${host}.sh > /target/root/ufw_${host}.sh
  /mnt/ufw_default.sh
  # Drop the ufw rules for future modification
  sed 's/^curtin in-target --target=\/target -- //' /mnt/ufw_default.sh > /target/root/ufw_default.sh
fi
