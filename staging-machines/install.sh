#!/bin/bash
# install eksctl 
## https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/eksctl.html
## 使用 ec2-user

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

aws eks update-kubeconfig --name tgs-taiwan-staging2

#現在執行 kubectl get pods 會出現 
#Unable to connect to the server: dial tcp 10.139.110.193:443: i/o timeout
#要在 EKS  叢集安全群組 
#加上 inbound rule 443  eks-cluster-sg-tgs-taiwan-staging2


# Install bash-completion
## https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/

yum install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exec bash
## exit 登出再登入


# helm 
https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# install aws-ebs-csi-driver

aws eks list-addons --cluster-name tgs-taiwan-staging2
aws eks create-addon --cluster-name tgs-taiwan-staging2 --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::060812454361:role/AmazonEKS_EBS_CSI_DriverRole


## https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
## https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

aws eks describe-cluster \
  --name tgs-taiwan-staging2 \
  --query "cluster.identity.oidc.issuer" \
  --output text

export oid=$(aws eks describe-cluster  --name tgs-taiwan-staging2   --query "cluster.identity.oidc.issuer"   --output text | cut -d '/' -f 5)

cat <<EOF | sudo tee ./aws-ebs-csi-driver-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::060812454361:oidc-provider/oidc.eks.ap-east-1.amazonaws.com/id/${oid}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.region-code.amazonaws.com/id/${oid}:aud": "sts.amazonaws.com",
          "oidc.eks.region-code.amazonaws.com/id/${oid}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

export csi_role_name=AmazonEKS_EBS_CSI_DriverRole_staging2

aws iam create-role \
  --role-name ${csi_role_name} \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}

kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::060812454361:role/${csi_role_name}

## for delete-role
#aws iam delete-role --role-name ${csi_role_name} 

#aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}
  

