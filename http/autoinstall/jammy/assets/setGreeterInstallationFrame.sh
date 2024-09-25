#!/bin/bash
EXEC_PATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

shopt -s expand_aliases
alias j2='/target/usr/bin/python3 /target/usr/bin/j2'

HEADER="Systeminstallation wird durchgeführt"
LINE1="Schalten Sie das System nicht aus!"
LINE2="Melden Sie sich nicht an!"
CFGFILE=$(mktemp)

# Set values for template usage
echo '{
    "warningHeader": "'"$HEADER"'",
    "warningLine1": "'"$LINE1"'",
    "warningLine2": "'"$LINE2"'"
}' > $CFGFILE

# Copy the warning template for future usage, too.
cp $EXEC_PATH/warning-frame.svg.j2 /target/usr/share/backgrounds/warning-frame.svg.j2

# Create a installation warning frame for current job
j2 -f json \
    /target/usr/share/backgrounds/warning-frame.svg.j2 \
    $CFGFILE \
        > /target/usr/share/backgrounds/frameInstallationWarning.svg

# Modify gdm greeter config
sed -i '/logo/c\logo='\''/usr/share/backgrounds/frameInstallationWarning.svg'\'' ' /target/etc/gdm3/greeter.dconf-defaults
