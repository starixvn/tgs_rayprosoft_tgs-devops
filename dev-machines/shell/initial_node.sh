#!/bin/bash

### 先設定固定IP
# cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
# network:
  # ethernets:
    # ens160:
      # addresses:
      # - 192.168.50.32/24
      # gateway4: 192.168.50.1
      # nameservers:
        # addresses:
        # - 8.8.8.8
        # - 8.8.4.4
  # version: 2
# EOF

#sudo netplan apply

#sudo hostnamectl set-hostname k8s-node-2


apt update && apt upgrade -y
swapoff -a
#nano /etc/fstab

sed -i /etc/fstab -e '/\/swap/ s/^#*/#/' 
sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL)NOPASSWD:ALL/g'

apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

K_VER="1.23.6-00"

## ubuntu 16.04 之後
apt-get install -y kubelet=${K_VER} kubectl=${K_VER} kubeadm=${K_VER}
#apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


### install docker ###

sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1g"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
 
### 設定防火牆
 
systemctl disable ufw && service ufw stop

sysctl -w net.ipv4.ip_forward=1

## uncomment #net.ipv4.ip_forward
## nano /etc/sysctl.conf
ipv4_ip_forward=net.ipv4.ip_forward
sed -i "s/^#$ipv4_ip_forward/$ipv4_ip_forward/g" /etc/sysctl.conf


### 安裝 nfs client

sudo apt-get install nfs-common -y
mkdir /nfsshare
chmod -R 777 /nfsshare
mount -t nfs 192.168.50.111:/nfsshare /nfsshare
	
### 安裝 helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


git clone https://lester.wei:1q2w3e4r@gitlab.com/rayprosoft/tgs-deployment.git


#kubeadm init --control-plane-endpoint "kube-api.rpgp.cc:6443" --upload-certs