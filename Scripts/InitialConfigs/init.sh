#!/bin/bash
# This script runs with the assumption of sudo priv
# Define the new content to be added
new_content="# Not for production use:
deb http://download.proxmox.debian bookworm pve-no-subscription"
kernel_content="# Enable Iommu support at boot:
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
"
# Define the file path for enterprise
pve_file_path="/etc/apt/sources.list.d/pve-enterprise.list"
ceph_file_path="/etc/apt/sources.list.d/ceph.list"
grub_default_path="/etc/default/grub"
# Remove any extra blank lines at the end of the file
sed -i '/^$/d' /etc/apt/sources.list
# Add a single blank line, then append the new content
echo -e "\n$new_content" | tee -a /etc/apt/sources.list > /dev/null

# Insert "#No subscription" above the line and comment out the "deb https..." line
sed -i '/^deb https:\/\/enterprise.proxmox.com\/debian\/pve bookworm pve-enterprise/ i #No subscription' "$pve_file_path"
sed -i 's|^deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise|#&|' "$pve_file_path"

# Insert "# disable enterprise" at the top and comment out the repository line
sed -i '1i # disable enterprise' "$ceph_file_path"
sed -i 's|^deb https://enterprise.proxmox.com/debian/ceph-quincy|#&|' "$ceph_file_path"

# Update the system
apt update -y && apt upgrade -y

# Enable IOMMU
#comment out for configuration purposes
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"/ i #configure iommu' "$grub_default_path"
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT="quiet"|#&|' "$grub_default_path"

# Add intel iommu support
sed -i '/^#\?GRUB_CMDLINE_LINUX_DEFAULT="quiet"/a\GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"' "$grub_default_path"
# Update Grub
update-grub

# Edit Kernel Modules
sed -i '/^$/d' /etc/modules && echo -e "\n$kernel_content" | tee -a /etc/modules > /dev/null

# Prevent subscription warning from appearing upon login to web gui
sed -Ezi.bak "s/(function\(orig_cmd\) \{)/\1\n\torig\(\);\n\treturn;/g" "/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js" && systemctl restart pveproxy.service

reboot