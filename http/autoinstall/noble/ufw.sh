#!/bin/bash

# UFW Konfiguration: restriktiv, nur Browser, DNS und apt-get Updates erlauben

echo "[*] Reset UFW policies..."
sudo ufw --force reset

echo "[*] Set standard-policies..."
sudo ufw default deny incoming
sudo ufw default deny outgoing

echo "[*] Permit basic outgoing traffic..."
sudo ufw allow out 80/tcp         # HTTP (Webseiten)
sudo ufw allow out 443/tcp        # HTTPS (Webseiten, apt-get)
sudo ufw allow out 53/udp         # DNS-Anfragen (UDP)
sudo ufw allow out 53/tcp         # DNS-Fallback (TCP)
sudo ufw allow out proto icmp     # (optional) ICMP für Ping

echo "[*] Permit NTP synchronization"
sudo ufw allow out 123/udp        # NTP (Zeitsynchronisation)

echo "[*] Permit internal networks (libvirt, Docker)..."
sudo ufw allow from 192.168.100.0/24
sudo ufw allow from 192.168.122.0/24
sudo ufw allow from 192.168.123.0/24
sudo ufw allow from 172.17.0.0/16

echo "[*] Permit public services on enp34s0..."
sudo ufw allow in on enp34s0 to any port 80 proto tcp
sudo ufw allow in on enp34s0 to any port 443 proto tcp
sudo ufw allow in on enp34s0 to any port 67 proto udp   # DHCP-Server (optional, nur falls du es brauchst)
sudo ufw allow in on enp34s0 to any port 69 proto udp   # TFTP (optional)

echo "[*] Block rest of outgoing traffic"
sudo ufw deny in on enp34s0
sudo ufw deny in on eno1

echo "[*] Enable UFW..."
sudo ufw --force enable

echo "[*] Print status:"
sudo ufw status verbose
