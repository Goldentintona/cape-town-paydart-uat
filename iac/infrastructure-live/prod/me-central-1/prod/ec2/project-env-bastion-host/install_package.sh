#!/bin/bash
sudo apt-get update
apt-get install vim -y
mkdir /root/openvpn
cd /root/openvpn
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
