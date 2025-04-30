#!/bin/bash

# UFW Configuration - CC01

echo "[*] Reset UFW policies..."
sudo ufw --force reset

echo "[*] Set default policies..."
sudo ufw default deny incoming
sudo ufw default deny outgoing

echo "[*] Allow basic outgoing traffic..."
sudo ufw allow out 80/tcp         # HTTP (web browsing)
sudo ufw allow out 443/tcp        # HTTPS (web browsing, apt-get)
sudo ufw allow out 53/udp         # DNS queries (UDP)
sudo ufw allow out 53/tcp         # DNS fallback (TCP)
sudo ufw allow out proto icmp     # (optional) ICMP for ping
sudo ufw allow out 22/tcp         # SSH (remote to VMs)

echo "[*] Allow NTP synchronization..."
sudo ufw allow out 123/udp        # NTP (time synchronization)

echo "[*] Allow internal networks (libvirt, Docker)..."
# libvirt isolated network
sudo ufw allow from 192.168.100.0/24
sudo ufw allow out to 192.168.100.0/24
# libvirt default network
sudo ufw allow from 192.168.122.0/24
sudo ufw allow out to 192.168.122.0/24
# libvirt pxe network
sudo ufw allow from 192.168.123.0/24
sudo ufw allow out to 192.168.123.0/24
# docker default network
sudo ufw allow from 172.17.0.0/16
sudo ufw allow out to 172.17.0.0/16

echo "[*] Allow public services for PXE based installations on enp34s0..."
sudo ufw allow in on enp34s0 to any port 80 proto tcp   # HTTP server
sudo ufw allow in on enp34s0 to any port 443 proto tcp  # HTTPS server
sudo ufw allow in on enp34s0 to any port 67 proto udp   # DHCP server (for PXE boot)
sudo ufw allow in on enp34s0 to any port 69 proto udp   # TFTP (optional)
sudo ufw allow in on enp34s0 to any port 22 proto tcp   # SSHd

echo "[*] Enable UFW..."
sudo ufw --force enable

echo "[*] Print status:"
sudo ufw status verbose