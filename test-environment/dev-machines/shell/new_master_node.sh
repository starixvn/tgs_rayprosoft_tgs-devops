#!/bin/bash
    1  apt update && apt upgrade -y
    2  swapoff -a
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
   
   14  kubeadm init --control-plane-endpoint "192.168.50.112:6443" --upload-certs
   15  cat /var/log/syslog
   16  cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
   17  cat /etc/kubernetes/bootstrap-kubelet.conf
   18  nano /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
   19  docker info | grep -i cgroup
   20  nano /etc/docker/daemon.json
   21  service docker restart
   22  docker info | grep -i cgroup
   23  kubeadm init --control-plane-endpoint "192.168.50.112:6443" --upload-certs
   24  kubeadm reset
   25  kubeadm init --control-plane-endpoint "192.168.50.112:6443" --upload-certs
   
   kubeadm init --control-plane-endpoint "kube-api.rpgp.cc:6443" --upload-certs
   
   26  cat /etc/docker/daemon.json
   27  cp /etc/kubernetes/admin.conf ~/.kube/config
   28  mkdir .kube/
   29  cp /etc/kubernetes/admin.conf ~/.kube/config
   30  kubectl get nodes
   31  kubectl describe nodes
   32  curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
   33  kubectl apply -f calico.yaml
   34  kubectl get pods -n kube-system
   35  watch kubectl get pods -n kube-system
   36  kubectl get nodes
   37  watch kubectl get nodes
   38  kubectl get pods
   39  kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl diff -f - -n kube-system
   40  # actually apply the changes, returns nonzero returncode on errors only
   41  kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
   42  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
   43  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
   44  kubectl get deploy
   45  kubectl get ns
   46  kubectl get --all -n metallb-system
   47  kubectl get all -n metallb-system
   48  kubectl edit deployment.apps/controller -n metallb-system
   49  wget https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
   50  tar -zxvf helm-v3.8.0-linux-amd64.tar.gz
   51  ls
   52  mv linux-amd64//helm /usr/local/bin/
   53  rm -fr linux-amd64/
   54  rm helm-v3.8.0-linux-amd64.tar.gz
   55  helm ls
   56  kubectl delete ns metallb-system
   57  ls
   58  helm repo add metallb https://metallb.github.io/metallb
   59  helm repo update
   60  mkdir helm
   61  cd helm/
   62  ls
   63  cd ..
   64  rm -fr helm/
   65  mkdir metallb
   66  cd metallb/
   67  ls
   68  nano values.yaml
   69  helm install metallb metallb/metallb -f values.yaml
   70  kubectl get pods
   86  kubectl get svc -A
   87  helm repo ls
   88  helm fetch metallb/metallb
   89  ls
   90  tar -zxvf metallb-0.12.1.tgz
   91  cd metallb/
   92  ls
   94  nano values.yaml
   95  helm ls
   96  helm del metallb
   97  cd
   98  ls
   99  mkdir nginx-ingress
  100  rm calico.yaml
  101  cd nginx-ingress/
  102  ls
  103  helm repo add nginx-stable https://helm.nginx.com/stable
  104  helm repo update
  105  helm install nginx nginx-stable/nginx-ingress
  106  kubectl get pods
  107  kubectl get svc
  108  ls
  109  helm fetch nginx-stable/nginx-ingress
  110  ls
  111  tar -zxvf nginx-ingress-0.12.1.tgz
  112  mv nginx-ingress/values.yaml .
  113  ls
  114  rm -fr nginx-ingress
  115  rm nginx-ingress-0.12.1.tgz
  116  nano values.yaml
  117  helm install nginx nginx-stable/nginx-ingress
  118  helmupgrade nginx nginx-stable/nginx-ingress
  119  helm upgrade nginx nginx-stable/nginx-ingress
  120  kubectl get pods
  121  kubectl get svc
  122  kubectl get ds
  123  kubectl get svc
  124  kubectl get pods
  125  kubectl get pods -o wide
  126  nano values.yaml
  127  kubectl get pods -o wide
  128  kubectl get pods
  129  kubectl get svc
  130  nano values.yaml
  131  helm del nginx
  132  helm install nginx nginx-stable/nginx-ingress
  133  kubectl get svc
  134  kubectl get pods
  135  kubectl get pods -o wide
  136  kubectl get deploy
  137  kubectl get ds
  138  nano values.yaml
  139  helm install nginx nginx-stable/nginx-ingress -f values.yaml
  140  helm upgrade nginx nginx-stable/nginx-ingress -f values.yaml
  141  kubectl get ds
  142  kubectl get pods
  143  kubectl get svc
  144  kubectl get pods
  145  kubectl get nodes
  146  kube label node k8s-node-1 node-role.kubernetes.io/worker=worker
  147  kubectl label node k8s-node-1 node-role.kubernetes.io/worker=worker
  148  kubectl label node k8s-node-2 node-role.kubernetes.io/worker=worker
  149  kubectl label node k8s-node-3 node-role.kubernetes.io/worker=worker
  150  kubectl label node k8s-node-4 node-role.kubernetes.io/worker=worker
  151  kubectl get nodes
  152  nano ~/.kube/c
  153  nano ~/.kube/config
  154  ifconfig
  155  reboot
  
  
   Unfortunately, an error has occurred:
                timed out waiting for the condition

        This error is likely caused by:
                - The kubelet is not running
                - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

        If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands:
                - 'systemctl status kubelet'
                - 'journalctl -xeu kubelet'

        Additionally, a control plane component may have crashed or exited when started by the container runtime.
        To troubleshoot, list all containers using your preferred container runtimes CLI.

        Here is one example how you may list all Kubernetes containers running in docker:
                - 'docker ps -a | grep kube | grep -v pause'
                Once you have found the failing container, you can inspect its logs with:
                - 'docker logs CONTAINERID'

error execution phase wait-control-plane: couldn't initialize a Kubernetes cluster
To see the stack trace of this error execute with --v=5 or higher