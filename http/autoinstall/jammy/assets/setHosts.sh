#!/bin/bash

# this helper script is necessary because of lack in handling variables in subiquity
source /mnt/hostValues 
echo "$ubuntu_proxy ubuntu-proxy" >> $1