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

velero restore create clusterrole --from-backup  clusterrole-1106
velero restore create rbac --from-backup  rbac-1106

./create-for-secrets.sh
./kubeconfig-convert.sh
