#!/bin/bash

# UFW Configuration - CC01

echo "[*] Reset UFW policies..."
curtin in-target --target=/target -- ufw --force reset

echo "[*] Set default policies..."
curtin in-target --target=/target -- ufw default deny incoming
curtin in-target --target=/target -- ufw default deny outgoing

echo "[*] Allow basic outgoing traffic..."
curtin in-target --target=/target -- ufw allow out 80/tcp         # HTTP (web browsing)
curtin in-target --target=/target -- ufw allow out 443/tcp        # HTTPS (web browsing, apt-get)
curtin in-target --target=/target -- ufw allow out 53/udp         # DNS queries (UDP)
curtin in-target --target=/target -- ufw allow out 53/tcp         # DNS fallback (TCP)
curtin in-target --target=/target -- ufw allow out 22/tcp         # SSH (remote to VMs)

echo "[*] Allow NTP synchronization..."
curtin in-target --target=/target -- ufw allow out 123/udp        # NTP (time synchronization)

echo "[*] Allow internal networks (libvirt, Docker)..."
# libvirt default network
curtin in-target --target=/target -- ufw allow from 192.168.122.0/24
curtin in-target --target=/target -- ufw allow out to 192.168.122.0/24
curtin in-target --target=/target -- ufw allow in on virbr0 to any
curtin in-target --target=/target -- ufw allow out on virbr0 to any
# libvirt pxe network
curtin in-target --target=/target -- ufw allow from 192.168.123.0/24
curtin in-target --target=/target -- ufw allow out to 192.168.123.0/24
# docker default network
curtin in-target --target=/target -- ufw allow from 172.17.0.0/16
curtin in-target --target=/target -- ufw allow out to 172.17.0.0/16
curtin in-target --target=/target -- ufw allow in on docker0 to any
curtin in-target --target=/target -- ufw allow out on docker0 to any

echo "[*] Enable UFW..."
curtin in-target --target=/target -- ufw --force enable
