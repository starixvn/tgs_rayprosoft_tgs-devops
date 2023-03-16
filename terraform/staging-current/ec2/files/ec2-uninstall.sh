#!/bin/bash
kubectl delete -f tgs-devops/terraform/deployment-files/ingresses/
kubectl delete -f tgs-devops/terraform/deployment-files/services/
kubectl delete -f tgs-devops/terraform/deployment-files/deployments/
kubectl delete -f tgs-devops/terraform/deployment-files/secrets/
kubectl delete -f tgs-devops/terraform/deployment-files/configmaps/



helm uninstall aws-load-balancer-controller -n kube-system 

helm uninstall nginx-ingress -n ingress-nginx

#eksctl delete addon --cluster tgs-taiwan-k8s --name aws-ebs-csi-driver --preserve


aws iam delete-policy \
    --policy-arn arn:aws:iam::060812454361:policy/AmazonEKSClusterAutoscalerPolicy 


eksctl delete iamserviceaccount \
  --cluster=tgs-taiwan-staging2 \
  --namespace=kube-system \
  --name=cluster-autoscaler


helm uninstall cert-manager -n cert-manager

bash tgs-devops/terraform/install-infra/delete_dns_record-staging.sh