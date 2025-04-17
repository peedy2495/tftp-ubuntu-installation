curtin in-target --target=/target -- systemctl disable snapd
curtin in-target --target=/target -- snap remove --purge lxd
curtin in-target --target=/target -- apt-get --purge -y --quiet=2 remove apport bcache-tools byobu friendly-recovery fwupd-signed landscape-common lxd-agent-loader ntfs-3g open-vm-tools plymouth plymouth-theme-ubuntu-text popularity-contest screen sosreport tmux
curtin in-target --target=/target -- apt-get --purge -y --quiet=2 remove snapd

cat > /target/etc/apt/preferences.d/nosnap.pref << 'EOF'
# To prevent repository packages from triggering the installation of snap,
# this file forbids snapd from being installed by APT.

Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

rm -rf /target/root/snap
rm -rf /target/snap
rm -rf /target/var/lib/snapd
rm -rf /target/var/snap
rm -rf /target/var/cache/snapd
rm -rf /target/usr/lib/snapd

# It's the final of cleanup ... ;-)
find /target -name 'snap*' -exec rm -rf {} +

curtin in-target -- apt update