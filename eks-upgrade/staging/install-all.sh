#!/bin/bash
aws eks update-kubeconfig --name tgs-k8s-staging

bash install-autoscaler.sh
bash install-csi-controller.sh
bash install-node-terminate-handler.sh

# install velero 
export namespace=staging
export BUCKET=tgs-staging-backup

cd
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket $BUCKET \
  --use-node-agent \
  --features=EnableCSI \
  --backup-location-config region=$REGION \
  --snapshot-location-config region=$REGION \
  --secret-file ./.credentials-velero

# ingress-controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
helm upgrade -i nginx ingress-nginx/ingress-nginx -f values-ingress-controller.yaml -n ingress-nginx

# cert-manager
# https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

sleep 10
# clusterissue
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ly.lester@rayprosoft.com
    privateKeySecretRef:
      name: letsencrypt-secret
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# install staging
velero restore create clusterrole --from-backup  clusterrole-1106
velero restore create rbac --from-backup  rbac-1106
velero restore create rabbitmq --from-backup rabbitmq-11-02  
velero restore create monitoring --from-backup monitoring-11-06 



## remove tls secrets
namespace=staging
for p in $(kubectl get secrets -n $namespace | grep tls | awk '{print $1}');do kubectl delete secrets $p -n $namespace; done;

## create serviceaccount secrets
ns=('staging' 'logging' 'monitoring' 'observability' 'rabbitmq-system' 'rabbitmq')
for namespace in ${ns[@]};do \
  for p in $(kubectl get sa -n $namespace | awk '{print $1}');do \
  kubectl apply -o yaml -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: $p
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "$p"
EOF
  done; \
done;


sudo grafana-backup restore --config=grafana-restore-stack.json  202311060515.tar.gz
sudo grafana-backup restore --config=grafana-restore.json  202311060654.tar.gz
