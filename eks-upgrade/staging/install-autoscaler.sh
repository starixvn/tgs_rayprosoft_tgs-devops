#!/bin/bash
export autoscaler_rolename=AmazonEKSClusterAutoscalerRole-tgs-k8s-staging
export autoscaler_policyname=AmazonEKSClusterAutoscalerPolicy-tgs-k8s-staging
export eks_cluster=tgs-k8s-staging
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

#aws iam delete-policy \
#	--policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname}

eksctl create iamserviceaccount \
  --cluster=${eks_cluster} \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::${account_id}:policy/${autoscaler_policyname} \
  --override-existing-serviceaccounts \
  --approve

cat <<EOF | sudo tee ./trust-policy.json
{ 
   "Version":"2012-10-17", 
   "Statement":[ 
      { 
         "Effect":"Allow", 
         "Principal":{ 
            "Federated": "arn:aws:iam::${account_id}:oidc-provider/oidc.eks.ap-east-1.amazonaws.com/id/${oid}"
         }, 
         "Action": ["sts:AssumeRoleWithWebIdentity"], 
         "Condition":{ 
            "StringEquals":{ 
               "oidc.eks.ap-east-1.amazonaws.com/id/${oid}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
            } 
         } 
      }
   ] 
}
EOF

aws iam create-role \
  --role-name ${autoscaler_rolename} \
  --assume-role-policy-document file://"trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname} \
  --role-name ${autoscaler_rolename}
  
## delete role
# 
aws iam detach-role-policy \
  --policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname} \
  --role-name ${autoscaler_rolename}
  
aws iam delete-role --role-name ${autoscaler_rolename} 

curl -O https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

## ADD
# - --balance-similar-node-groups
# - --skip-nodes-with-system-pods=false 
sed -i "s/<YOUR CLUSTER NAME>/${eks_cluster}\n            - --balance-similar-node-groups\n            - --skip-nodes-with-system-pods=false/g" cluster-autoscaler-autodiscover.yaml

kubectl apply -f cluster-autoscaler-autodiscover.yaml

kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${account_id}:role/${autoscaler_rolename}

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl rollout restart deploy cluster-autoscaler -n kube-system
#kubectl set image deployment cluster-autoscaler \
#  -n kube-system \
#  cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.25.n
sleep 15
kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler