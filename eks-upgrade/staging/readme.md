# install velero 
export BUCKET=tgs-staging-backup

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket $BUCKET \
  --use-node-agent \
  --features=EnableCSI \
  --backup-location-config region=$REGION \
  --snapshot-location-config region=$REGION \
  --secret-file ./.credentials-velero

velero backup create clusterrole-1106 --include-resources clusterrole,clusterrolebinding
velero backup create rbac-1106 --include-namespaces staging  --include-resources serviceaccounts,secrets,roles,rolebindings
velero backup create rabbitmq-11-02 --include-namespaces rabbitmq,rabbitmq-system

velero restore create clusterrole --from-backup  clusterrole-1106
velero restore create rbac --from-backup  rbac-1106
velero restore create rabbitmq --from-backup rabbitmq-11-02  


./create-for-secrets.sh
./kubeconfig-convert.sh


# install ingress-controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
helm upgrade -i nginx ingress-nginx/ingress-nginx -f values-ingress-controller -n ingress-nginx
