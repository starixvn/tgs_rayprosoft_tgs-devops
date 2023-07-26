#!/bin/bash
apt update
apt install nfs-common -y
mkdir -p /nfsshare
mount -t nfs 192.168.50.111:/nfsshare /nfsshare
sed -i '$a192.168.50.111:/nfsshare /nfsshare nfs defaults 0 0' /etc/fstab
ls /nfsshare