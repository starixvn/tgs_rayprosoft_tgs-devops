## REF
https://github.com/justmeandopensource/kubernetes/tree/master/kubeadm-ha-keepalived-haproxy/external-keepalived-haproxy

## Disable swap
```
swapoff -a; sed -i '/swap/d' /etc/fstab
```
## Disable Firewall
```
systemctl disable --now ufw
```
## Enable and Load Kernel modules
```
{
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
}
```

## Add Kernel settings
```
{
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
}
```


## Install Containerd
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
https://docs.docker.com/engine/install/ubuntu/
```
{
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
}
```

## Add apt repo for kubernetes
```
{
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
}
```

## Install Kubernetes components
```
{
  apt update
  apt install -y kubeadm kubelet kubectl
}
```

```
#{
#  apt update
#  apt install -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00
#}
```
## configure kubeadmin-config
```
{
cat > kubeadmin-config <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.27.3
controlPlaneEndpoint: kube-api.rpgp.cc:6443
networking:
  podSubnet: "10.144.0.0/16"
etcd:
  external:
    endpoints:
    - https://192.168.50.71:2379
    - https://192.168.50.72:2379
    - https://192.168.50.73:2379
    caFile: /etc/kubernetes/pki/etcd/ca.pem
    certFile: /etc/kubernetes/pki/etcd/etcd.pem
    keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "192.168.50.63"
EOF
}
```
```
kubeadm init --upload-certs --v=5 --config kubeadm-config.yaml --dry-run

kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.tigera.io/archive/v3.25/manifests/calico.yaml
```
