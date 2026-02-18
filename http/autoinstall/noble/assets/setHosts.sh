#!/bin/bash

# this helper script is necessary because of lack in handling variables in subiquity
exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/hostValues

echo "$nexus_c2 nexus-c2" >> $1
