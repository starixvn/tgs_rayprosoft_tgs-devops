#!/bin/bash
export csi_role_name=AmazonEKS_EBS_CSI_DriverRole-tgs-k8s-prod
export csi_sa_name=ebs-csi-controller-sa
export eks_cluster=tgs-k8s-prod
export account_id=060812454361
export region=ap-east-1
export oid=$(aws eks describe-cluster --name ${eks_cluster} --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo ${oid}

aws eks list-addons --cluster-name ${eks_cluster}

## aws eks delete-addon --cluster-name tgs-taiwan-staging2 --addon-name aws-ebs-csi-driver \
##  --service-account-role-arn arn:aws:iam::${account_id}:role/${csi_role_name}


## https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
## https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

aws eks describe-cluster \
  --name ${eks_cluster} \
  --query "cluster.identity.oidc.issuer" \
  --output text

cat <<EOF | sudo tee ./aws-ebs-csi-driver-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${account_id}:oidc-provider/oidc.eks.${region}.amazonaws.com/id/${oid}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${region}.amazonaws.com/id/${oid}:aud": "sts.amazonaws.com",
          "oidc.eks.${region}.amazonaws.com/id/${oid}:sub": "system:serviceaccount:kube-system:${csi_sa_name}"
        }
      }
    }
  ]
}
EOF


## delete role
aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}
  
aws iam delete-role --role-name ${csi_role_name}

aws iam create-role \
  --role-name ${csi_role_name} \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}

aws eks create-addon --cluster-name ${eks_cluster} --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::${account_id}:role/${csi_role_name}
    
# kubectl annotate serviceaccount ${csi_sa_name} \
    # -n kube-system \
    # eks.amazonaws.com/role-arn=arn:aws:iam::${account_id}:role/${csi_role_name}

sleep 10

kubectl rollout restart deploy ebs-csi-controller -n kube-system

rm aws-ebs-csi-driver-trust-policy.json