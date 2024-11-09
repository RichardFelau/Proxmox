I encountered another issue tonight with proxmox. I noticed an error in the systemlogs showing:

Nov 06 21:47:22 pve1 rrdcached[37896]: handle_request_update: Could not read RRD file.
Nov 06 21:47:22 pve1 pmxcfs[799]: [status] notice: RRDC update error /var/lib/rrdcached/db/pve2-node/pve1: -1
Nov 06 21:47:22 pve1 pmxcfs[799]: [status] notice: RRD update error /var/lib/rrdcached/db/pve2-node/pve1: mmaping file '/var/lib/rrdcached/db/pve2-node/pve1': Invalid argument

Over and over again.

I restarted the rrdcached service, however, this did not fix the issue.
Since this is a new instance of proxmox, I did not have any important information logged in the rddcached db for pve1 as of yet, so I removed it at:
/var/lib/rrdcached/db/pve2-node/pve1

after removing, restart the rrdcached service to regenerate the pve1 db node:
systemctl restart rrdcached

This seemed to fixed the issue, as there were no more error messages appearing.