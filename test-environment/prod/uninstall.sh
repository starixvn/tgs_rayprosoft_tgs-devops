#!/bin/bash
helm uninstall fluent-bit -n logging
helm uninstall log-center -n logging
helm uninstall nginx-ingress -n nginx-ingress
helm uninstall prometheus-stack -n monitoring 
kubectl delete -f k8s-installation/observability/jaeger-eck.yml
kubectl delete -f k8s-installation/observability/elasticsearch-eck-prod.yaml
kubectl delete -f k8s-installation/observability/kibana-eck-prod.yaml
kubectl delete -f k8s-installation/rabbitmq/rabbitmq.yaml


## for delete csi role
export csi_role_name=AmazonEKS_EBS_CSI_DriverRole-prod2
aws iam delete-role --role-name ${csi_role_name} 
aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name ${csi_role_name}

## delete autoscaling role
export autoscaler_rolename=AmazonEKSClusterAutoscalerRole-prod2
export autoscaler_policyname=AmazonEKSClusterAutoscalerPolicy-prod2
export eks_cluster=tgs-taiwan-k8s2
export account_id=060812454361

aws iam delete-role --role-name ${autoscaler_rolename} 
eksctl delete iamserviceaccount \
  --cluster=${eks_cluster} \
  --namespace=kube-system \
  --name=cluster-autoscaler 
aws iam delete-policy --policy-arn arn:aws:iam::${account_id}:policy/${autoscaler_policyname}