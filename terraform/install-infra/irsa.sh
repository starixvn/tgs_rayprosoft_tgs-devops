# https://aws.amazon.com/tw/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/
# https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html
# https://aws.amazon.com/tw/premiumsupport/knowledge-center/eks-restrict-s3-bucket/
#!/bin/bash

AWS_REGION=ap-east-1
cluster=tgs-taiwan-staging2
account_id=$(aws sts get-caller-identity --query "Account" --output text)
oidc_provider=$(aws eks describe-cluster --name ${cluster} --region $AWS_REGION --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
namespace=default
service_account=eks-irsa-sa
policy_name=eks-irsa-policy

aws eks describe-cluster --name tgs-taiwan-staging2 --query "cluster.identity.oidc.issuer" --output text


cat >iam-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "List",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
				"s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
EOF


aws iam create-policy \
    --policy-name ${policy_name} \
    --policy-document file://iam-policy.json


 
cat >trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name eks-irsa-role --assume-role-policy-document file://trust-relationship.json --description "eks-role-description"



eksctl create iamserviceaccount \
  --name ${service_account} \
  --namespace ${namespace} \
  --cluster ${cluster} \
  --attach-policy-arn arn:aws:iam::${account_id}:policy/${policy_name} \
  --override-existing-serviceaccounts
  --approve
 

eksctl create iamserviceaccount \
  --name eks-irsa-sa2 \
  --namespace default \
  --cluster tgs-taiwan-staging2 \
  --attach-policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy \
  --override-existing-serviceaccounts \
  --approve
 
 eksctl create iamserviceaccount \
  --name eks-irsa-sa \
  --namespace default \
  --cluster tgs-taiwan-staging2 \
  --attach-policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy \
  --approve
  
  


### remove
kubectl delete -f pod.yaml
kubectl delete sa eks-irsa-sa2
aws iam list-policy-versions --policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy
aws iam delete-policy-version --policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy --version-id v1
aws iam delete-policy --policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy 
aws iam list-policy-versions --query "Versions[].VersionId" --policy-arn arn:aws:iam::118936045135:policy/eks-irsa-policy --output text 
aws iam delete-role  --role-name eks-irsa-role
aws iam delete-role  --role-name eksctl-tgs-taiwan-staging2-addon-iamservicea-Role1-1MMEGB6EXY78W
 