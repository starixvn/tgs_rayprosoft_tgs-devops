#!/bin/bash

mkdir -p $HOME/.aws 

cat <<EOT >> $HOME/.aws/credentials
[default]
aws_access_key_id = AKIARXMJEAZHQXZMA45B
aws_secret_access_key = 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
EOT

cat <<EOT >> $HOME/.aws/config
[default]
region = ap-east-1
EOT


aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-k8s

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo add eks https://aws.github.io/eks-charts