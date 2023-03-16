#!/bin/bash

### 先設定固定IP
cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    ens160:
      addresses:
      - 192.168.50.161/24
      gateway4: 192.168.50.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
  version: 2
EOF

sudo netplan apply

# sudo hostnamectl set-hostname k8s-node-2

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


sudo systemctl daemon-reload
sudo systemctl restart docker
 
### 設定防火牆
 
systemctl disable ufw && service ufw stop

curl https://10.96.0.1 -k

sysctl -w net.ipv4.ip_forward=1
nano /etc/sysctl.conf

curl http://220.132.206.70


### 安裝 nfs client

sudo apt-get install nfs-common -y


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

kubectl label node k8s-elasticsearch-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-node-2 node-role.kubernetes.io/worker=worker
kubectl label node k8s-node-3 node-role.kubernetes.io/worker=worker

kubectl label node k8s-elasticsearch-1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-2 node-role.kubernetes.io/worker=worker
kubectl label node k8s-elasticsearch-3 node-role.kubernetes.io/worker=worker

kubectl label node k8s-elasticsearch-1 type=elasticsearch-test
kubectl label node k8s-elasticsearch-2 type=elasticsearch-test
kubectl label node k8s-elasticsearch-3 type=elasticsearch-test

kubectl taint nodes k8s-elasticsearch-1 type=elasticsearch-test:NoSchedule
kubectl taint nodes k8s-elasticsearch-2 type=elasticsearch-test:NoSchedule
kubectl taint nodes k8s-elasticsearch-3 type=elasticsearch-test:NoSchedule

kubeadm certs certificate-key
kubeadm token create --print-join-command
kubeadm init phase upload-certs --upload-certs


kubeadm join kube-api.rpgp.cc:6443 \
	--token c0u5sk.bdsgpliiwpqegn7q --discovery-token-ca-cert-hash sha256:f3f6d5bfc6f54b0ec6aadc151b683ec7916d34f4b58674aae97bb0d0155787c0 \
	--control-plane --certificate-key 7b9d2490f8c74619a3211ac3b5a2fbad248305c9f32890a2adec5f41bd825b55


kubeadm join kube-api.rpgp.cc:6443 --token r4knut.fzibz6mb3apvn635 \
   --discovery-token-ca-cert-hash sha256:f3f6d5bfc6f54b0ec6aadc151b683ec7916d34f4b58674aae97bb0d0155787c0 \
   --control-plane --certificate-key 335f92e40116ed0b8a670997847303add57b706986c02885345b7404f7dcc3aa

kubeadm join kube-api.rpgp.cc:6443 --token ed9h24.8g0y28hp9h5e8ca5 \
	--discovery-token-ca-cert-hash sha256:feb5f905c0461d13698d9547a8452c3890a82ef9ee4ea77e3838f13a5230c9c1 \
	--control-plane --certificate-key e4da87fe92f4e596ecea3cc6e58b1fbb4ee4f4280a1d0048ba80c5cee5e57bec


kubeadm join kube-api.rpgp.cc:6443 --token vi2yp5.iez24sxlfb2kx5tf \
	--discovery-token-ca-cert-hash sha256:47a5959aff44632a9ce5ff0c9176f9fb86bf31face5570e753afa02e5684d8a9 \
	--control-plane --certificate-key ab36ec2a2cbe9c6a5b3456129f5b6058412302e83f25d25bfb696d7786b66d9e



kubeadm join kube-api.rpgp.cc:6443 --token 1ykxj9.9qgnhqqxamzuevlt --discovery-token-ca-cert-hash sha256:47a5959aff44632a9ce5ff0c9176f9fb86bf31face5570e753afa02e5684d8a9 --control-plane --certificate-key 20e5d994d4777c511b4541c52249c50dd0757ee1f7efcf6c3e6642e571c435e5

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


### calico
https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart

kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml

### ingress
https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters
    
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/baremetal/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/baremetal/deploy.yaml

*** 修改 nginx.conf 的 http, https port
	
### cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml


### helm 
https://helm.sh/docs/intro/install/

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
  