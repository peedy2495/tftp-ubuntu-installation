#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

ubuntuPartition=$(efibootmgr| grep ubuntu | cut -d '*' -f1 | sed 's/Boot//')
bootPartition=$(efibootmgr| grep BootOrder | cut -d ':' -f2 | cut -d ',' -f1 | xargs)

if [ "$ubuntuPartition" != "$bootPartition" ]; then
    echo "Inorrect Bootorder - fixing"
    bootOrderPart=$(efibootmgr| grep BootOrder |cut -d ':' -f2 | sed s/${ubuntuPartition}//| sed 's/,,/,/' | xargs | sed 's/^,*//'| sed 's/,*$//')
    newBootOrder="$ubuntuPartition,$bootOrderPart"
    efibootmgr -o $newBootOrder
else
    echo "Bootorder is correct ... nothing to do"
fi