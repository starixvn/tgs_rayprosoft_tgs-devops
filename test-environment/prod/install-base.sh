#!/bin/bash
# install aws-cli 
## https://docs.aws.amazon.com/zh_tw/cli/latest/userguide/getting-started-install.html

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# install eksctl 
## https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/eksctl.html
## 使用 ec2-user

# export PATH='/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin:/root/bin:/usr/local/bin'
export PATH=$PATH:'/usr/local/bin'
echo $PATH
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

aws eks update-kubeconfig --name tgs-taiwan-k8s2 <<<

#現在執行 kubectl get pods 會出現 
#Unable to connect to the server: dial tcp 10.139.110.193:443: i/o timeout
#要在 EKS  叢集安全群組 
#加上 inbound rule 443  eks-cluster-sg-tgs-taiwan-k8s2     10.139.0.0/16


# Install bash-completion
## https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/

apt install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exec bash
## exit 登出再登入


# helm 
# https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
