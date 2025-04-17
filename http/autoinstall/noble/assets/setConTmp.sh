#!/bin/bash
exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/hostValues
dev="$(ip link show | grep UP | tail -n1 | cut -d ':' -f2 | sed 's/ //g')"

ip addr add $con_ip_tmp dev $dev