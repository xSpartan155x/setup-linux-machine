#!/bin/bash

# var
ssh="22"

# todo insert custom var

# todo ask for confirm and if the ssh key is in the /home/user/ dir

# Update System
sudo apt update && sudo apt upgrade -y
echo Sistema aggiornato 
sleep 2s

# Install Firewall
sudo apt install ufw
echo UFW Installato
sleep 2s

# Install Fail2ban
sudo apt install fail2ban
echo fail2ban Installato
sleep 2s

# Install 2FA Authenticator
sudo apt install libpam-google-authenticator
echo googleAuthenticator Installato
sleep 2s

# Set ssh key
cat ~/*.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
rm ~/*.pub
echo "Ssh Keys set" 
sleep 2s

# Set UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit $ssh
sudo ufw enable
sudo systemctl start ufw
sudo systemctl status ufw
echo "Firewall set"
sleep 2s

# Set Fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# todo add write on file
# [sshd]
# enabled = true
# port = ssh
# filter = sshd
# logpath = /var/log/auth.log
# maxretry = 3
# bantime = -1
# action = ufw-ban
sudo nano /etc/fail2ban/action.d/ufw-ban.conf
# todo add write on file
# [Definition]
# actionstart = ufw
# actionstop = ufw
# actionban = ufw insert 1 deny from <ip> to any
# actionunban = ufw delete deny from <ip> to any
echo "Fail2ban set"
sleep 2s

# Set Google Authenticator
sudo google-authenticator
sudo nano /etc/pam.d/sshd
# todo add write on file
# auth required pam_google_authenticator.so
echo "Goole Authenticato set"
sleep 2s

# Restart All
sudo systemctl restart ssh/sshd
sudo systemctl restart fail2ban
sudo systemctl restart ufw
echo "All System restarted"
sleep 2s

# Check Status
sudo systemctl status ssh/sshd
sudo systemctl status fail2ban
sudo systemctl status fail2ban sshd
sudo systemctl status ufw
echo "All Online"
sleep 2s