#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Prompt for SSH port
read -p "Enter the SSH port to configure: " SSH_PORT

# Update and upgrade the system
echo "Updating and upgrading the system..."
apt update && apt upgrade -y
sleep 2s

# Install UFW and Fail2Ban
echo "Installing UFW and Fail2Ban..."
apt install -y ufw fail2ban libpam-google-authenticator
sleep 2s

# Configure SSH
SSHD_CONFIG="/etc/ssh/sshd_config"
echo "Configuring SSH..."
sed -i "s/^#\?Port .*/Port $SSH_PORT/" $SSHD_CONFIG
sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" $SSHD_CONFIG
sed -i "s/^#\?AuthorizedKeysFile .*/AuthorizedKeysFile .ssh\/authorized_keys/" $SSHD_CONFIG
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" $SSHD_CONFIG
sed -i "s/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication yes/" $SSHD_CONFIG
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" $SSHD_CONFIG
sed -i "s/^#\?UsePAM .*/UsePAM yes/" $SSHD_CONFIG

echo "AuthenticationMethods publickey,keyboard-interactive" >> $SSHD_CONFIG

sleep 2s
# Handle included config files
if grep -q "^Include /etc/ssh/sshd_config.d/*.conf" $SSHD_CONFIG; then
  echo "Checking included config files for contradictions..."
  for file in /etc/ssh/sshd_config.d/*.conf; do
    if [ -f "$file" ]; then
      sed -i "s/^#\?Port .*/Port $SSH_PORT/" $file
      sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" $file
      sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" $file
    fi
  done
fi

sleep 2s
# Restart SSH
systemctl restart sshd

# Configure UFW
echo "Configuring UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw limit $SSH_PORT
read -p "Enter additional ports to allow (comma-separated, or leave blank): " ADDITIONAL_PORTS
IFS="," read -ra PORTS <<< "$ADDITIONAL_PORTS"
for PORT in "${PORTS[@]}"; do
  ufw allow $PORT
done
ufw enable
sleep 2s

# Configure Google Authenticator
echo "Configuring Google Authenticator..."
google-authenticator -t -d -f -r 3 -R 30 -W
PAM_SSHD="/etc/pam.d/sshd"
if ! grep -q "auth required pam_google_authenticator.so" $PAM_SSHD; then
  echo "auth required pam_google_authenticator.so" >> $PAM_SSHD
fi
sleep 2s

# Configure Fail2Ban
echo "Configuring Fail2Ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/^\[sshd\].*/[sshd]\nenabled = true\nport = $SSH_PORT\nfilter = sshd\nlogpath = \/var\/log\/auth.log\nmaxretry = 3\nbantime = -1\naction = ufw-ban/" /etc/fail2ban/jail.local

cat <<EOF > /etc/fail2ban/action.d/ufw-ban.conf
[Definition]
actionstart = ufw
actionstop = ufw
actionban = ufw insert 1 deny from <ip> to any
actionunban = ufw delete deny from <ip> to any
EOF

sleep 2s
systemctl restart fail2ban
systemctl restart ufw

# Restart services and check status
systemctl restart sshd
systemctl restart fail2ban
systemctl restart ufw

# Show statuses
echo "Checking statuses..."
systemctl status sshd --no-pager
systemctl status fail2ban --no-pager
systemctl status ufw --no-pager

echo "Setup complete."
