#!/bin/bash

### 先設定固定IP
cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    ens160:
      addresses:
      - 192.168.50.109/24
      gateway4: 192.168.50.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
  version: 2
EOF

sudo netplan apply

#!/bin/bash
# sudo hostnamectl set-hostname k8s-node-2
# stop popup daemons-using-outdated-libraries
# https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf


# Check current value of max_user_instances:
# https://blog.csdn.net/weixin_44277627/article/details/122173531
echo 256 > /proc/sys/fs/inotify/max_user_instances
sed -i '$afs.inotify.max_user_instances = 256' /etc/sysctl.conf

### 安裝 nfs client
sudo apt-get install nfs-common -y
mkdir /nfsshare
chmod -R 777 /nfsshare
mount -t nfs 192.168.50.111:/nfsshare /nfsshare
sed -i '$a192.168.50.111:/nfsshare /nfsshare nfs defaults 0 0\n' /etc/fstab

### 開始安裝
apt update && apt upgrade -y
swapoff -a
## nano /etc/fstab  
sed -e '/\/swap/ s/^#*/#/' -i /etc/fstab


apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

### install containerd prepare###
### https://kubernetes.io/docs/setup/production-environment/container-runtimes/

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install Containerd
## https://github.com/containerd/containerd/blob/main/docs/getting-started.md
## https://docs.docker.com/engine/install/ubuntu/

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
sudo apt-get update
sudo apt-get install containerd.io

containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd

kubeadm join kubeapi.rpgp.cc:6443 --token rv2h6b.wrh4tlifh33qor7n --discovery-token-ca-cert-hash sha256:c4d8dd05213dd87a87f7e2d7c2719cf23149b9ba5f8780a0511cc8f040cae2ba