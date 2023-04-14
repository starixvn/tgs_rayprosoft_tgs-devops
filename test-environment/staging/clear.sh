#!/bin/bash
export csi_role_name=AmazonEKS_EBS_CSI_DriverRole-staging2
export autoscaler_rolename=AmazonEKSClusterAutoscalerRole-staging2
export autoscaler_policyname=AmazonEKSClusterAutoscalerPolicy-staging2
export account_id=060812454361

## for delete csi role

aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name} 
  
aws iam delete-role --role-name ${csi_role_name} 

## for delete autoscaler role

aws iam detach-role-policy \
  --policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname} \
  --role-name ${autoscaler_rolename}

aws iam delete-policy \
  --policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname}

aws iam delete-role --role-name ${autoscaler_rolename}
