#!/bin/bash
USERNAME="ubuntu"
USER_HOME="/home/$USERNAME"
SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"


# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown $USERNAME:$USERNAME "$SSH_DIR"

# Create authorized_keys file if it doesn't exist
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown $USERNAME:$USERNAME "$AUTHORIZED_KEYS"

echo ${public_ssh_key} >> "$AUTHORIZED_KEYS"



sudo apt update && apt -y install net-tools wireguard
 
# https://github.com/vainkop/terraform-aws-wireguard/blob/master/templates/user-data.txt
sudo mkdir -p /etc/wireguard
sudo cat > /etc/wireguard/wg0.conf <<- EOF
[Interface]
PrivateKey = ${wg_private_key}
ListenPort = ${wg_port}
Address = ${wg_cidr}
PostUp = sysctl -w -q net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ENI -j MASQUERADE
PostDown = sysctl -w -q net.ipv4.ip_forward=0
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ENI -j MASQUERADE
 
${wg_peers}
EOF
 
# Make sure we replace the "ENI" placeholder with the actual network interface name
export ENI=$(ip route get 8.8.8.8 | grep 8.8.8.8 | awk '{print $5}')
sudo sed -i "s/ENI/$ENI/g" /etc/wireguard/wg0.conf
 
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0