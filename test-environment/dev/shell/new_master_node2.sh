#!/bin/bash
    1  reboot
    2  apt update && apt upgrade -y
    3  swapoff -a
    4  nano /etc/fstab t
    5  apt-get update && sudo apt-get install -y apt-transport-https curl
    6  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    7  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    8  deb https://apt.kubernetes.io/ kubernetes-xenial main
    9  EOF
   10  apt-get update
   11  apt-get install -y kubelet kubeadm kubectl
   12  apt-mark hold kubelet kubeadm kubectl
   13  apt-get install docker.io -y
   14  nano /etc/docker/daemon.json
   15  service docker restart
   16  kubeadm join 192.168.50.112:6443 --token urooc6.9s9duetg42y2h5n1         --discovery-token-ca-cert-hash sha256:31a2e11a27a36885b65f42df024a6b5be2558968a87ffd978674d117e68fc391         --control-plane --certificate-key 5a99ba96270e484f2315a7db95a0c4d26e14f13d0d9bf0001398fcfd834feade
   17  reboot
   
   
    1  kubectl get nodes
    2  apt update && apt upgrade -y
    3  swapoff -a
    4  nano /etc/fstab
    5  apt-get update && sudo apt-get install -y apt-transport-https curl
    6  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    7  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    8  deb https://apt.kubernetes.io/ kubernetes-xenial main
    9  EOF
   10  apt-get update
   11  apt-get install -y kubelet kubeadm kubectl
   12  apt-mark hold kubelet kubeadm kubectl
   13  apt-get install docker.io -y
   14  nano /etc/docker/daemon.json
   15  service docker restart
   16  kubeadm join 192.168.50.112:6443 --token urooc6.9s9duetg42y2h5n1         --discovery-token-ca-cert-hash sha256:31a2e11a27a36885b65f42df024a6b5be2558968a87ffd978674d117e68fc391         --control-plane --certificate-key 5a99ba96270e484f2315a7db95a0c4d26e14f13d0d9bf0001398fcfd834feade
