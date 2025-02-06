![](./assets/img/header.png)

# 💻 Setup Linux Ubuntu Server ![](https://skillicons.dev/icons?i=linux,ubuntu)

Hi this is a little Tutorial to how to setup a Linux Ubuntu Server and the security.

## 🔧 Requiremnts 

- Internet Connection
- Basic Knowledge of Linx Ubuntu
- A linux machine local or remote
- A computer for connect to the server

## 🟧 Legend

For a better protection all steps are important.

- color 🟥 important
- color 🟧 less important
- color 🟩 non important

## ⚪️ Step 1: Update and Upgrade the System 🟧

```sh 
sudo apt update && sudo apt upgrade -y 
```

## ⚪️ Step 2: Generate a ssh key pair on client machine 🟥

```sh
ssh-keygen -t rsa -b 4096 -C "Email or Identifier"
```
or

```sh
ssh-keygen -t ed25519 -C "Email or Identifier"
```
## Diffrence between RSA and Ed25519

### RSA:

- Based on the difficulty of factoring large numbers.
- Keys are larger (2048+ bits) for equivalent security.
- Slower for signing and verifying compared to modern algorithms.
- Common in legacy systems and applications requiring compatibility.
### Ed25519 (suggested):

- Based on elliptic curve cryptography (specifically Curve25519).
- Smaller keys (256 bits) with high security and performance.
- Much faster signing and verification.
- Designed for modern use cases, with a focus on efficiency and resistance to side-channel attacks.

## ⚪️ Step 3: Copy the public key to the server 🟥

```sh
scp ~/.ssh/keyid.pub username@server:~/nameofuser_ed25519.pub
scp ~/.ssh/keyid.pub username@server:~/nameofuser_rsa.pub

```

## ⚪️ Step 4: Add the public key to the server 🟥

``` sh
cat ~/nameofuser_ed25519.pub >> ~/.ssh/authorized_keys
```

## ⚪️ Step 5: Change the permissions of the authorized_keys file 🟥

```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## ⚪️ Step 6: Remove the public key file from the home directory 🟥

```sh
rm ~/nameofuser_ed25519.pub
```
## ⚪️ Step 7: change sshd_config 🟥

```sh
sudo nano /etc/ssh/sshd_config
```
sshd_config:

```sh
Port change it
PubkeyAuthentication yes
AuthorizedKeysFile    .ssh/authorized_keys
PermitRootLogin no
ChallengeResponseAuthentication yes
PasswordAuthentication no
AuthenticationMethods publickey, keyboard-interactive
UsePam yes
```

if there is Include path like(Include /etc/ssh/sshd_config.d/*.conf)
check the path to the config and remove any contradiction

```sh
sudo nano /etc/ssh/sshd_config.d/*.conf
```

## ⚪️ Step 8: Install UFW (Uncomplicated Firewall) 🟥

```sh
sudo apt install ufw
```
check if it's correctly installed 

```sh
ufw version
```
or

```sh
sudo ufw version
```
## ⚪️ Step 9: Setup UFW 🟥

ssh = The SSH port previously configured
ports = Ports you need to be opend in your machine

```sh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh
sudo ufw allow ports
sudo ufw enable
```

## ⚪️ Step 10: Start and Check status UFW 🟥

```sh
sudo systemctl start ufw
sudo systemctl status ufw
```
## ⚪️ Step 11: Install google authenticator 🟧

```sh
sudo apt install libpam-google-authenticator
```

## ⚪️ Step 12: Configure Google Authenticator 🟧

```sh
sudo google-authenticator
```
### Follow the instructions:

Scan the QR code with a TOTP app like Google Authenticator, Authy, or similar.
Answer the questions to configure the behavior (e.g., if you want to allow multiple codes in case of time synchronization issues).

### Check file /etc/pam.d/sshd

```sh
sudo nano /etc/pam.d/sshd
```

sshd: 

```sh
auth required pam_google_authenticator.so
```

## ⚪️ Step 13: Install Fail2Ban 🟧

```sh
sudo apt install fail2ban
```
## ⚪️ Step 14: Setup Fail2Ban 🟧

```sh
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```
jail.local: 

ssh = The SSH port previously configured

```sh
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = -1
action = ufw-ban
```
Create custom config fail2ban

```sh
sudo nano /etc/fail2ban/action.d/ufw-ban.conf
```

ufw-ban.conf:

```sh
[Definition]
actionstart = ufw
actionstop = ufw
actionban = ufw insert 1 deny from <ip> to any
actionunban = ufw delete deny from <ip> to any
```

## ⚪️ Step 15: Restart SSH UFW FAIL2BAN 🟧

```sh
sudo systemctl restart ssh/sshd
sudo systemctl restart fail2ban
sudo systemctl restart ufw
```

## ⚪️ Step 16: Check status 🟥

```sh
sudo systemctl status ssh/sshd
sudo systemctl status fail2ban
sudo systemctl status fail2ban sshd
sudo systemctl status ufw
```

## ⚪️ Step 17: Test SSH connection with Google Authenticator 🟥

```sh
ssh -p Port user@hostname
```

## ❤️ Thank you for visiting!

I hope this helped you

___

💻💖 by [xSpartan155x](https://github.com/xSpartan155x)
