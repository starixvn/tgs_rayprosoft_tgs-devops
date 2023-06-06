#!/bin/bash

### 先設定固定IP
export myip=$(hostname -I)
cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    ens160:
      addresses:
      - $myip/24
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

export master_url=$myip:6443

kubeadm join $master_url --token rv2h6b.wrh4tlifh33qor7n --discovery-token-ca-cert-hash sha256:c4d8dd05213dd87a87f7e2d7c2719cf23149b9ba5f8780a0511cc8f040cae2ba
kubeadm join $master_url --token 1q5s0s.ijkwtfpxyni0t3vs --discovery-token-ca-cert-hash sha256:c4d8dd05213dd87a87f7e2d7c2719cf23149b9ba5f8780a0511cc8f040cae2ba


# for master node
# REF　https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#configuring-the-kubelet-cgroup-driver

cat <<EOF | sudo tee /root/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.27.0
controlPlaneEndpoint: $master_url
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF


kubeadm init --config kubeadm-config.yaml

kubeadm init --control-plane-endpoint "kube-api.rpgp.cc:6443" --upload-certs --v=5 --config kubeadm-config.yaml

kubeadm init --upload-certs --v=5 --config kubeadm-config.yaml --dry-run


mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config



kubeadm join kubeapi.rpgp.cc:6443 --token rv2h6b.wrh4tlifh33qor7n --discovery-token-ca-cert-hash sha256:c4d8dd05213dd87a87f7e2d7c2719cf23149b9ba5f8780a0511cc8f040cae2ba \
--control-plane --certificate-key 9cf4006f4e4e99acd219f8c8da9806953e1a99cb9cf01d61b9e1d22f12d3b656 --dry-run


kubeadm join kubeapi.rpgp.cc:6444 --token zwzb7u.vk3e83ocr6xqquke \
        --discovery-token-ca-cert-hash sha256:a40b8ce32f4b2e0e3e148d015db08ff3d18a8391a5eba859816290864edf8d5b \
        --control-plane --certificate-key 77d3f6a176b608f0f0408ef1dcc8aeef4b1209ad9e4b1a44292439dcfa2d66bd
		

kubeadm join kubeapi.rpgp.cc:6444 --token zwzb7u.vk3e83ocr6xqquke \
        --discovery-token-ca-cert-hash sha256:a40b8ce32f4b2e0e3e148d015db08ff3d18a8391a5eba859816290864edf8d5b
		

kubectl label node k8s-elasticsearch-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-2 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-3 node-role.kubernetes.io/worker=worker

kubectl label node k8s2-node-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s2-node-2 node-role.kubernetes.io/worker=worker
kubectl label node k8s2-node-3 node-role.kubernetes.io/worker=worker


# install calico 
https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises

=> manifest

curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
sed -i 's/# - name: CALICO_IPV4POOL_CIDR/- name: CALICO_IPV4POOL_CIDR\n              value: "172.16.0.0\/16"/g'  calico.yaml
kubectl apply -f calico.yaml

 
### 設定防火牆
 
systemctl disable ufw && service ufw stop

curl https://10.96.0.1 -k

sysctl -w net.ipv4.ip_forward=1
nano /etc/sysctl.conf

curl http://220.132.206.70


### 安裝 nfs client

sudo apt-get install nfs-common -y

### 安裝 nfs client
sudo apt-get install nfs-common -y
mkdir /nfsshare
chmod -R 777 /nfsshare
mount -t nfs 192.168.50.111:/nfsshare /nfsshare
sed -i '$a192.168.50.111:/nfsshare /nfsshare nfs defaults 0 0\n' /etc/fstab


### 下面這段不必要
nano /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  ==> Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"
  ==> $KUBELET_CGROUP_ARGS
sudo systemctl daemon-reload && systemctl restart kubelet
systemctl status kubelet



kubeadm init --control-plane-endpoint "kube-api.rpgp.cc:6443" --upload-certs --v=5

kubeadm join kube-api.rpgp.cc:6443 --token cv630a.o2w11y1osh1nxkbb \
        --discovery-token-ca-cert-hash sha256:47a5959aff44632a9ce5ff0c9176f9fb86bf31face5570e753afa02e5684d8a9 
		\ 
		--control-plane --certificate-key ad93f9b6d81deaa50f1143be669ec205d4dc9c206bbff08bb0ae159e6c7ec722

kubeadm reset
rm -rf /etc/cni/net.d


apt-cache madison kubeadm

kubectl label node k8s-master-1 node-role.kubernetes.io/worker=master
kubectl label node k8s-master-2 node-role.kubernetes.io/worker=master
kubectl label node k8s-master-3 node-role.kubernetes.io/worker=master

kubectl label node k8s-elasticsearch-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-node-01 node-role.kubernetes.io/worker=worker
kubectl label node k8s-node-3 node-role.kubernetes.io/worker=worker

kubectl label node k8s-elasticsearch-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-2 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-3 node-role.kubernetes.io/worker=worker

kubectl label node k8s-elasticsearch-1 node-type=elasticsearch
kubectl label node k8s-elasticsearch-2 node-type=elasticsearch
kubectl label node k8s-elasticsearch-3 node-type=elasticsearch


kubectl label node k8s-node-01 node-type=normal
kubectl label node k8s-node-02 node-type=normal



kubectl taint nodes k8s-elasticsearch-1 type=elasticsearch-test:NoSchedule
kubectl taint nodes k8s-elasticsearch-2 type=elasticsearch-test:NoSchedule
kubectl taint nodes k8s-elasticsearch-3 type=elasticsearch-test:NoSchedule

kubeadm certs certificate-key

kubeadm token create --print-join-command
kubeadm init phase upload-certs --upload-certs

kubeadm join kubeapi.rpgp.cc:6443 --token rv2h6b.wrh4tlifh33qor7n --discovery-token-ca-cert-hash sha256:c4d8dd05213dd87a87f7e2d7c2719cf23149b9ba5f8780a0511cc8f040cae2ba \
--control-plane --certificate-key 9cf4006f4e4e99acd219f8c8da9806953e1a99cb9cf01d61b9e1d22f12d3b656 --dry-run



kubeadm join kube-api.rpgp.cc:6443 \
	--token j9sjaj.qdm99jfw4ql5tfm8 --discovery-token-ca-cert-hash sha256:47a5959aff44632a9ce5ff0c9176f9fb86bf31face5570e753afa02e5684d8a9 \
	--control-plane --certificate-key 06ba291ed4904a0cfa9adc0a77e44b10dd252c210b6a743c3891483700ee0fe6


alias etcdctl='etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key'


### Install bash-completion
### https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/

apt-get install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exec bash
exit 登出再登入


### helm 
https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


### calico
https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart

kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml


https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises




### ingress
https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters
    
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/baremetal/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/baremetal/deploy.yaml

*** 修改 nginx.conf 的 http, https port
	
### cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml




### metric-server 
https://github.com/kubernetes-sigs/metrics-server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl edit deploy  metrics-server -n kube-system
deploy args 要加上 - --kubelet-insecure-tls

### reloader 
https://github.com/stakater/Reloader

kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml


### nfs provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
  
helm repo update

helm install nfs-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=192.168.50.111 \
  --set nfs.path=/nfsshare \
  --set storageClass.name=nfs-provisioner
  