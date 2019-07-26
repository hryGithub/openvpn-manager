#!/bin/bash

print_help () {
  echo -e "./desinstall.sh www_basedir"
  echo -e "\tbase_dir: The place where the web application is in"
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Ensure there are enought arguments
if [ "$#" -ne 1 ]; then
  print_help
  exit
fi

www=$1

if [ ! -d "$www" ]; then
  print_help
  exit
fi

echo -e "\033[1mAre you sure to completely delete OpenVPN configurations, the web application (with the sqlite database) ? (yes/*)\033[0m"
read agree

if [ "$agree" != "yes" ]; then
  exit
fi

# Files delete (openvpn confs/keys + web application)
rm -r /etc/openvpn/easy-rsa/
rm -r /etc/openvpn/{ccd,scripts,server.conf,ca.crt,ta.key,server.crt,server.key,dh*.pem}
rm -r "$www"

# Remove rooting rules
echo 0 > "/proc/sys/net/ipv4/ip_forward"
sed -i '/net.ipv4.ip_forward = 1/d' '/etc/sysctl.conf'

echo "The application has been completely removed!"
echo "Please remove the openvpn firewall rules manually!"
