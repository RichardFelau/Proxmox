#!/bin/bash

# Install base packages
DEBIAN_FRONTEND=noninteractive apt install -y iptables fail2ban auditd logwatch rsyslog clamav apparmor htop glances lynis psad iptables-persistent
# Save default configs
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6


# Initial Config
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
# Allow SSH through
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 8006 -j ACCEPT
#Save Configuration
netfilter-persistent save

# Configure Fail2Ban
# SSH Configuration:
# nano /etc/fail2ban/jail.conf
# [sshd]
# enabled = true
# port = 22
# filter = sshd
# logpath = /var/log/auth.log
# maxretry = 5
# bantime = 10m



# Configure Auditd
# nano /etc/audit/auditd.conf
# max_log_file = 10

# Add rules to /etc/audit/rules.d/audit.rules
# -w /etc/passwd -p wa -k passwd_change
# -w /etc/shadow -p wa -k shadow_change
# -w /var/log/wtmp -p wa -k logins
# -w /var/log/btmp -p wa -k failed_logins



# psad internal port scanner detection
ENABLE_AUTO_IDS  Y;

EMAIL_ADDRESSES "Enter Email Address"
iptables -A INPUT -j LOG
iptables -A FORWARD -j LOG
netfilter-persistent save


lynis audit system --quiet --report-file ~/lynis_scans.txt

freshclam

clamscan -r --quiet / --log=/var/log/clamav/clamav_detections.log