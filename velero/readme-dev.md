# velero backup && restore
###### tags: `velero`
## REF: https://github.com/vmware-tanzu/velero-plugin-for-aws
## REF: https://github.com/vmware-tanzu/velero/releases

###  安裝velero
    wget https://github.com/vmware-tanzu/velero/releases/download/v1.12.0-rc.1/velero-v1.12.0-rc.1-linux-arm64.tar.gz
    
    tar zxvf velero-v1.12.0-rc.1-linux-arm64.tar.gz
    cp velero-v1.12.0-rc.1-linux-arm6/velero /usr/local/bin


    cat <<EOF | sudo tee ~/.credentials-velero
    [default]
    aws_access_key_id=AKIAQ4KFUNHMUZU6QD2V
    aws_secret_access_key=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
    EOF

    export BUCKET=tgs-dev-backup
    export BUCKET=tgs-staging-backup
    export BUCKET=tgs-prod-backup
    export REGION=ap-east-1

    velero install \
        --provider aws \
        --plugins velero/velero-plugin-for-aws:v1.12.0 \
        --bucket $BUCKET \
        --backup-location-config region=$REGION \
        --snapshot-location-config region=$REGION \
        --secret-file ./.credentials-velero

## Check
velero backup-location get
### 移除velero
https://velero.io/docs/v1.3.0/uninstalling/

    velero uninstall 
    或 
    kubectl delete namespace/velero clusterrolebinding/velero
    kubectl delete crds -l component=velero

### 建立備份
https://velero.io/docs/v1.12/resource-filtering/

    velero backup create test-dev --include-namespaces dev
    velero backup create test --exclude-namespaces kube-system,kube-public,kube-node-lease,ingress-nginx,velero --include-resources configmaps,serviceaccounts,secrets,certificates,orders,rs,services,deployments,daemonsets,statefulsets,cronjobs,roles,rolebindings,ingresses,persistentvolumes,persistentvolumeclaims
    velero backup create test --include-namespaces staging --include-resources configmaps,serviceaccounts,secrets,services,deployments,daemonsets,statefulsets,cronjobs,roles,rolebindings,ingresses
    

### 建立排程
    velero schedule create sctest0325 --schedule "*/3 * * * *"
    velero schedule create sctest0325 --include-namespace aa --schedule="@daily" --ttl 2160h0m0s
    
    velero schedule create daily-eks --include-namespaces dev --schedule="@daily"  --ttl 2160h0m0s
    velero schedule create daily-eks --exclude-namespaces kube-system,kube-public,kube-node-lease,ingress-nginx,velero --schedule="@daily"  --ttl 2160h0m0s
    velero schedule create prod-k8s --schedule="0 0 * * *" --exclude-namespaces kube-system,kube-public,kube-node-lease,velero --schedule="@daily"  --ttl 2160h0m0s --include-resources configmaps,serviceaccounts,secrets,certificates,orders,rs,services,deployments,daemonsets,statefulsets,cronjobs,roles,rolebindings,ingresses,persistentvolumes,persistentvolumeclaims
    velero schedule create dev-k8s --include-namespaces prod --schedule="@daily"  --ttl 2160h0m0s --include-resources configmaps,serviceaccounts,certifacates,orders,secrets,services,deployments,daemonsets,statefulsets,cronjobs,roles,rolebindings,ingresses
    
### 建立還原
    velero restore create test1 --from-backup dev-k8s-20230726000012
    velero restore create --from-schedule sc
    velero restore create --from-backup backup-2 --include-resources persistentvolumeclaims,persistentvolumes
