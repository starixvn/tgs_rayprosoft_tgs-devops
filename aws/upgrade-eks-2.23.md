
# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi-migration-faq.html

## How can I check whether the Amazon EBS CSI driver is installed in my cluster?

aws eks list-addons --cluster-name tgs-taiwan-staging

aws eks create-addon --cluster-name tgs-taiwan-staging --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::060812454361:role/AmazonEKS_EBS_CSI_DriverRole
  

# https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

aws eks describe-cluster \
  --name tgs-taiwan-staging \
  --query "cluster.identity.oidc.issuer" \
  --output text
  
https://oidc.eks.ap-east-1.amazonaws.com/id/86827905697FB66246F1CE1BB01DDE33

cat <<EOF | sudo tee ./aws-ebs-csi-driver-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::060812454361:oidc-provider/oidc.eks.ap-east-1.amazonaws.com/id/86827905697FB66246F1CE1BB01DDE33"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.region-code.amazonaws.com/id/86827905697FB66246F1CE1BB01DDE33:aud": "sts.amazonaws.com",
          "oidc.eks.region-code.amazonaws.com/id/86827905697FB66246F1CE1BB01DDE33:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF


aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole

kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::060812454361:role/AmazonEKS_EBS_CSI_DriverRole


kubectl rollout restart deployment ebs-csi-controller -n kube-system


###### PROD

aws eks create-addon --cluster-name tgs-taiwan-k8s --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::060812454361:role/AmazonEKS_EBS_CSI_DriverRole
  
aws eks list-addons --cluster-name tgs-taiwan-k8s


aws eks describe-cluster \
  --name tgs-taiwan-k8s \
  --query "cluster.identity.oidc.issuer" \
  --output text
 
https://oidc.eks.ap-east-1.amazonaws.com/id/3CD7C11793811D1AB1605FFB918728EA

cat <<EOF | sudo tee ./aws-ebs-csi-driver-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::060812454361:oidc-provider/oidc.eks.ap-east-1.amazonaws.com/id/3CD7C11793811D1AB1605FFB918728EA"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.region-code.amazonaws.com/id/3CD7C11793811D1AB1605FFB918728EA:aud": "sts.amazonaws.com",
          "oidc.eks.region-code.amazonaws.com/id/3CD7C11793811D1AB1605FFB918728EA:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF


aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole

kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::060812454361:role/AmazonEKS_EBS_CSI_DriverRole


kubectl rollout restart deployment ebs-csi-controller -n kube-system
