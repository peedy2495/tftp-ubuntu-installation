#!/bin/bash
EXEC_PATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

HEADER="Systeminstallation wird durchgeführt"
LINE1="Schalten Sie das System nicht aus!"
LINE2="Melden Sie sich nicht an!"
CFGFILE=$(mktemp)

echo '{
    "warningHeader": "'"$HEADER"'",
    "warningLine1": "'"$LINE1"'",
    "warningLine2": "'"$LINE2"'"
}' > $CFGFILE

j2 -f json \
    $EXEC_PATH/warning-frame.svg.j2 \
    $CFGFILE \
        > /target/usr/share/backgrounds/frameWarning.svg

sed -i '/logo/c\logo='\''/usr/share/backgrounds/frameWarning.svg'\'' ' /target/etc/gdm3/greeter.dconf-defaults
