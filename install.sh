#!/bin/bash

print_help () {
  echo -e "./install.sh www_basedir"
  echo -e "\tbase_dir: The place where the web application will be put in,it should be not exit"
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

# Ensure there are the prerequisites
for i in openvpn php bower node unzip wget sed sqlite3; do
  which $i > /dev/null
  if [ "$?" -ne 0 ]; then
    echo "Miss $i"
    exit
  fi
done

www=$1

# Check the validity of the arguments
if [ -d "$www" ] ; then
  print_help
  exit
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


printf "\n################## Server informations ##################\n"

read -p "Server Hostname/IP: " ip_server

read -p "OpenVPN protocol (tcp or udp) [tcp]: " openvpn_proto

if [[ -z $openvpn_proto ]]; then
  openvpn_proto="tcp"
fi

read -p "Port [443]: " server_port

if [[ -z $server_port ]]; then
  server_port="443"
fi

printf "\n################## Setup database ##################\n"
read -p "sqlite database dir[defalut $www/data]:" db_dir
if [[ -z $db_dir ]]; then
  db_dir=$www/data
fi

if [ -f $db_dir/openvpn-manager.db ];then
	echo "The openvpn-manager database already exists."
	exit
fi

printf "\n################## Certificates informations ##################\n"

read -p "Key size (1024, 2048 or 4096) [2048]: " key_size

read -p "Root certificate expiration (in days) [3650]: " ca_expire

read -p "Certificate expiration (in days) [3650]: " cert_expire

read -p "Country Name (2 letter code) [US]: " cert_country

read -p "State or Province Name (full name) [California]: " cert_province

read -p "Locality Name (eg, city) [San Francisco]: " cert_city

read -p "Organization Name (eg, company) [Copyleft Certificate Co]: " cert_org

read -p "Organizational Unit Name (eg, section) [My Organizational Unit]: " cert_ou

read -p "Email Address [me@example.net]: " cert_email

read -p "Common Name (eg, your name or your server's hostname) [ChangeMe]: " key_cn


printf "\n################## Creating the certificates ##################\n"

EASYRSA_RELEASES=( $(
  curl -s https://api.github.com/repos/OpenVPN/easy-rsa/releases | \
  grep 'tag_name' | \
  grep -E '3(\.[0-9]+)+' | \
  awk '{ print $2 }' | \
  sed 's/[,|"|v]//g'
) )
EASYRSA_LATEST=${EASYRSA_RELEASES[0]}

# Get the rsa keys
wget "https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz"
tar -xaf "EasyRSA-unix-v3.0.6.tgz"
mv "EasyRSA-v3.0.6" /etc/openvpn/easy-rsa
rm "EasyRSA-unix-v3.0.6.tgz"

cd /etc/openvpn/easy-rsa

if [[ ! -z $key_size ]]; then
  export EASYRSA_KEY_SIZE=$key_size
fi
if [[ ! -z $ca_expire ]]; then
  export EASYRSA_CA_EXPIRE=$ca_expire
fi
if [[ ! -z $cert_expire ]]; then
  export EASYRSA_CERT_EXPIRE=$cert_expire
fi
if [[ ! -z $cert_country ]]; then
  export EASYRSA_REQ_COUNTRY=$cert_country
fi
if [[ ! -z $cert_province ]]; then
  export EASYRSA_REQ_PROVINCE=$cert_province
fi
if [[ ! -z $cert_city ]]; then
  export EASYRSA_REQ_CITY=$cert_city
fi
if [[ ! -z $cert_org ]]; then
  export EASYRSA_REQ_ORG=$cert_org
fi
if [[ ! -z $cert_ou ]]; then
  export EASYRSA_REQ_OU=$cert_ou
fi
if [[ ! -z $cert_email ]]; then
  export EASYRSA_REQ_EMAIL=$cert_email
fi
if [[ ! -z $key_cn ]]; then
  export EASYRSA_REQ_CN=$key_cn
fi

# Init PKI dirs and build CA certs
./easyrsa init-pki
./easyrsa build-ca nopass
# Generate Diffie-Hellman parameters
./easyrsa gen-dh
# Genrate server keypair
./easyrsa build-server-full server nopass

# Generate shared-secret for TLS Authentication
openvpn --genkey --secret pki/ta.key


printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"
mkdir "/etc/openvpn/ccd"
sed -i "s/port 443/port $server_port/" "/etc/openvpn/server.conf"

if [ $openvpn_proto = "udp" ]; then
  sed -i "s/proto tcp/proto $openvpn_proto/" "/etc/openvpn/server.conf"
fi

nobody_group=$(id -ng nobody)
sed -i "s/group nogroup/group $nobody_group/" "/etc/openvpn/server.conf"

printf "\n################## Setup firewall ##################\n"

# Make ip forwading and make it persistent
echo 1 > "/proc/sys/net/ipv4/ip_forward"
echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"

# Get primary NIC device name
primary_nic=`route | grep '^default' | grep -o '[^ ]*$'`

if [ -x "$(command -v firewall-cmd)" ]; then
  # firewall-cmd
  firewall-cmd --add-port=$server_port/$openvpn_proto --permanent
  #firewall-cmd --zone=trusted --add-service openvpn
  #firewall-cmd --zone=trusted --add-service openvpn --permanent
  firewall-cmd --add-masquerade --permanent
  firewall-cmd --reload
elif [ -x "$command -v ufw" ]; then
  # ufw
  sed "/# Don't delete these/i \
  # START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from OpenVPN client to eth0 (change to the interface ou discovered!)\n-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES " -i /etc/ufw/before.rules
  sed 's/\(DEFAULT_FORWARD_POLICY="\)\(.*\)"/\1ACCEPT"/'  /etc/ufw/before.rules
  ufw allow $server_port/$openvpn_proto
  ufw allow OpenSSH
else
  # Iptable rules
  iptables -I FORWARD -i tun0 -j ACCEPT
  iptables -I FORWARD -o tun0 -j ACCEPT
  iptables -I OUTPUT -o tun0 -j ACCEPT

  iptables -A FORWARD -i tun0 -o $primary_nic -j ACCEPT

  iptables -t nat -A POSTROUTING -o $primary_nic -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $primary_nic -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o $primary_nic -j MASQUERADE
fi


printf "\n################## Setup web application ##################\n"

# Copy bash scripts (which will insert row in Sqlite)
cp -r "$base_path/installation/scripts" "/etc/openvpn/"
chmod +x "/etc/openvpn/scripts/"*

# Configure database in openvpn scripts
sed -i "s/DB=''/DB=$db_dir/openvpn-manager.db/" "/etc/openvpn/scripts/config.sh"

# Create the directory of the web application
mkdir "$www/data" -p
cp -r "$base_path/"{index.php,sql,bower.json,.bowerrc,js,include,css,installation/client-conf} "$www"


# New workspace
cd "$www"

# Replace in the client configurations with the ip of the server and openvpn protocol
for file in for file in "./client-conf/gnu-linux/client.conf" "./client-conf/osx-viscosity/client.conf" "./client-conf/windows/client.ovpn";do
  sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server $server_port/" $file
  echo "<ca>" >> $file
  cat "/etc/openvpn/ca.crt" >> $file
  echo "</ca>" >> $file
  echo "<tls-auth>" >> $file
  cat "/etc/openvpn/ta.key" >> $file
  echo "</tls-auth>" >> $file

  if [ $openvpn_proto = "udp" ]; then
    sed -i "s/proto tcp-client/proto udp/" $file
  fi
done

# Install third parties
bower --allow-root install

printf "\033[1m\n#################################### Finish ####################################\n"

echo -e "# Congratulations, you have successfully setup OpenVPN-Admin! #\r"
echo -e "Please, finish the installation by configuring your web server (Apache, NGinx...)"
echo -e "and install the web application by visiting http://your-installation/index.php?installation\r"
echo -e "Then, you will be able to run OpenVPN with systemctl start openvpn@server\r"
echo "Please, report any issues here https://github.com/hryGithub/openvpn-manager.git"
printf "\n################################################################################ \033[0m\n"
