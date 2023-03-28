
# install eksctl 
## https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/eksctl.html
## 使用 ec2-user

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

aws eks update-kubeconfig --name tgs-taiwan-staging2

現在執行 kubectl get pods 會出現 
Unable to connect to the server: dial tcp 10.139.110.193:443: i/o timeout


要在 EKS  叢集安全群組 
加上 inbound rule 443  eks-cluster-sg-tgs-taiwan-staging2


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


export oid=$(aws eks describe-cluster   --name tgs-taiwan-staging2   --query "cluster.identity.oidc.issuer"   --output text | cut -d '/' -f 5)

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
aws iam delete-role --role-name ${csi_role_name} 

aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}

# ingress-controller
## for class load balancer
### ingress-nginx-controller

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create ns ingress-nginx

helm -n ingress-nginx install nginx-ingress ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"

helm uninstall nginx-ingress

## for network load balancer
## https://repost.aws/knowledge-center/eks-access-kubernetes-services

wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
kubectl apply -f deploy.yaml


# metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


# cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# rabbitmq
## https://www.rabbitmq.com/kubernetes/operator/operator-overview.html
## https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"


git clone https://gitlab.com/rayprosoft/tgs-devops.git

## go to k8s-installation/rabbitmq
kubectl create ns rabbitmq
kubectl apply -f rabbitmq.yaml
kubectl apply -f ingress.yaml

https://blog.csdn.net/qq_24095055/article/details/97001679

kubectl exec -it  mq-server-0 /bin/bash -n rabbitmq

rabbitmqctl add_user tgs TgsP@ssw0rd

rabbitmqctl add_vhost /tgs/dev
rabbitmqctl add_vhost /tgs/staging
rabbitmqctl add_vhost /tgs/prod

rabbitmqctl set_permissions -p "/tgs/dev" "tgs" '.*' '.*' '.*'
rabbitmqctl set_permissions -p "/tgs/staging" "tgs" '.*' '.*' '.*'
rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
rabbitmqctl set_user_tags tgs administrator

# Cluster Autoscaler
# https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/autoscaling.html

export eks_cluster=tgs-taiwan-staging2
export account_id=060812454361

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
    --policy-name AmazonEKSClusterAutoscalerPolicy-staging2 \
    --policy-document file://cluster-autoscaler-policy.json

aws iam delete-policy \
	--policy-arn arn:aws:iam::${account_id}:policy/AmazonEKSClusterAutoscalerPolicy-staging2

eksctl create iamserviceaccount \
  --cluster=${eks_cluster} \
  --namespace=kube-system \
  --name=cluster-autoscaler-staging2 \
  --attach-policy-arn=arn:aws:iam::${account_id}:policy/AmazonEKSClusterAutoscalerPolicy-staging2 \
  --override-existing-serviceaccounts \
  --approve
 

curl -O https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

kubectl apply -f cluster-autoscaler-autodiscover.yaml

kubectl annotate serviceaccount cluster-autoscaler-staging2 \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${account_id}:role/AmazonEKSClusterAutoscalerRole

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl -n kube-system edit deployment.apps/cluster-autoscaler


