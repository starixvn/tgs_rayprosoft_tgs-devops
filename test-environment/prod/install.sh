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

aws eks update-kubeconfig --name tgs-taiwan-k8s2

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

# install aws-ebs-csi-driver
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export csi_role_name=AmazonEKS_EBS_CSI_DriverRole-staging2
export csi_sa_name=ebs-csi-controller-sa
export eks_cluster=tgs-taiwan-staging2
export oid=$(aws eks describe-cluster --name ${eks_cluster} --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo ${oid}

aws eks list-addons --cluster-name ${eks_cluster}
aws eks create-addon --cluster-name ${eks_cluster} --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::060812454361:role/${csi_role_name}
  
## aws eks delete-addon --cluster-name tgs-taiwan-staging2 --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::060812454361:role/${csi_role_name}



## https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
## https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

aws eks describe-cluster \
  --name ${eks_cluster} \
  --query "cluster.identity.oidc.issuer" \
  --output text

kubectl create secret generic aws-secret \
    --namespace kube-system \
    --from-literal "key_id=${AWS_ACCESS_KEY_ID}" \
    --from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"
	
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
          "oidc.eks.region-code.amazonaws.com/id/${oid}:sub": "system:serviceaccount:kube-system:${csi_sa_name}"
        }
      }
    }
  ]
}
EOF



aws iam create-role \
  --role-name ${csi_role_name} \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}

kubectl annotate serviceaccount ${csi_sa_name} \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::060812454361:role/${csi_role_name}

kubectl rollout restart deploy ebs-csi-controller -n kube-system

## for delete-role
#aws iam delete-role --role-name ${csi_role_name} 

#aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}


# autoscaler

export autoscaler_rolename=AmazonEKSClusterAutoscalerRole-prod2
export autoscaler_policyname=AmazonEKSClusterAutoscalerPolicy-prod2
export eks_cluster=tgs-taiwan-k8s2
export account_id=060812454361
export oid=$(aws eks describe-cluster --name ${eks_cluster} --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo ${oid}

cat <<EOF | sudo tee ./cluster-autoscaler-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/${eks_cluster}": "owned"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:DescribeLaunchTemplateVersions",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy \
    --policy-name ${autoscaler_policyname} \
    --policy-document file://cluster-autoscaler-policy.json

aws iam delete-policy \
	--policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname}

eksctl create iamserviceaccount \
  --cluster=${eks_cluster} \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::${account_id}:policy/${autoscaler_policyname} \
  --override-existing-serviceaccounts \
  --approve
  

cat <<EOF | sudo tee ./trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${account_id}:oidc-provider/oidc.eks.ap-east-1.amazonaws.com/id/${oid}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-east-1.amazonaws.com/id/${oid}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }
  ]
}
EOF


aws iam create-role \
  --role-name ${autoscaler_rolename} \
  --assume-role-policy-document file://"trust-policy.json"
## delete role
aws iam delete-role --role-name ${autoscaler_rolename} 

curl -O https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

kubectl apply -f cluster-autoscaler-autodiscover.yaml



kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${account_id}:role/${autoscaler_rolename}

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl -n kube-system edit deployment.apps/cluster-autoscaler

ADD
 - --balance-similar-node-groups
 - --skip-nodes-with-system-pods=false


kubectl rollout restart deploy cluster-autoscaler -n kube-system


kubectl set image deployment cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.25.n

kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler


