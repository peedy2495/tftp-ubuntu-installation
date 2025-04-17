ufw enable


## Default Regeln
sudo ufw default deny incoming
sudo ufw default allow outgoing

## Interne libvirt Netze freigeben 
sudo ufw allow from 192.168.100.0/24
sudo ufw allow from 192.168.122.0/24
sudo ufw allow from 192.168.123.0/24

## Docker freigeben
sudo ufw allow from 172.17.0.0/16

## Öffentliche Dienste auf enp34s0 erlauben
sudo ufw allow in on enp34s0 to any port 80 proto tcp
sudo ufw allow in on enp34s0 to any port 443 proto tcp
sudo ufw allow in on enp34s0 to any port 67 proto udp
sudo ufw allow in on enp34s0 to any port 69 proto udp
sudo ufw allow out on enp34s0 to any port 68 proto udp

## Danach: Externes Interface blockieren
sudo ufw deny in on enp34s0

## Eigehenden Verkehr aus dem Internet blockieren
ufw deny in on eno1
