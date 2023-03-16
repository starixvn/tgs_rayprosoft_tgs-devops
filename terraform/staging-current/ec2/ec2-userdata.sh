#!/bin/bash
yum update -y
timedatectl set-timezone "Asia/Taipei"
localectl set-locale LANG=zh_TW.UTF-8          
touch /home/ec2-user/.hushlogin
chown ec2-user:ec2-user /home/ec2-user/.hushlogin

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip  -d /tmp/awscliv2/
/tmp/awscliv2/aws/install

curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y gcc-c++ make
yum install -y nodejs

## new
yum install -y git
yum install -y jq
git clone https://lester.wei:1q2w3e4r@gitlab.com/rayprosoft/tgs-devops.git

chmod 0400 /home/ec2-user/tgs-key.pem
mkdir -p /home/ec2-user/.aws 

cat <<EOT >> /home/ec2-user/.aws/credentials
[default]
aws_access_key_id = AKIAQ4KFUNHM5WIUBA4L
aws_secret_access_key = 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
EOT

cat <<EOT >> /home/ec2-user/.aws/config
[default]
region = ap-east-1
EOT

sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH=$PATH:/usr/local/bin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"