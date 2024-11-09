Today I ran into an issue with a fresh install of proxmox 8.2.
After installing, and setting up the hyper-visor, I was not able to connect to the web gui. Initial steps taken was to ping proxmox. This was successful. I then attempted to ssh into the instance, which was also successful.
My thought here was that if I was able to ping, and ssh in, then there had to be some kind of issue with the web client itself. I attempted to curl 10.5.4.10:8006 on my lan. Nothing came back.
Knowing that proxmox comes with a self-signed certs for ssl connection out of the box, I decided to attempt to renew them using the following command:
pvecm updatecerts --force

This failed, saying could not read private key from /etc/pve/priv/pve-root-ca.key
Weird.
I decide before moving forward to take a look at the proxy service for proxymox:
systemctl status pveproxy

This came back as running, however I did see an error showing for /etc/pve/local/pve-ssl.pem: failed to use local certificate chain).
This confirmed my suspicion that something was wrong with the certs.
from here I decided to check the permissions for the certs, to make sure they were in order:
ls -l /etc/pve/priv/
-rw------- 1 root www-data 0 Jan 26  2024 /etc/pve/priv/pve-root-ca.key

huh... This is all that showed up. Permissions were correct... but it was showing 0 data. the cert authority key was empty, which explains the failure to sign our certs.
Next I decided to remove the key, and start again:

rm /etc/pve/priv/pve-root-ca.key
pvecm updatecerts --force
(re)generate node files
generate new node certificate
merge authorized SSH keys
creating directory '/etc/pve/firewall' for observed files
creating directory '/etc/pve/ha' for observed files
creating directory '/etc/pve/mapping' for observed files
creating directory '/etc/pve/priv/acme' for observed files
creating directory '/etc/pve/sdn' for observed files

After checking the web gui at 10.5.4.10:8006, I was finally able to connect.