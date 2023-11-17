# update kubeconfig

cd tgs-devops/eks-upgrade/prod

aws eks update-kubeconfig --name tgs-k8s-prod

bash install-autoscaler.sh
# install csi-controller
# install node-terminate-handler
# install velero 
export namespace=prod
export BUCKET=tgs-prod-backup

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
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

# metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# reloader 
## https://github.com/stakater/Reloader

kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml

# Install Elastic Cloud on Kubernetes
# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html

kubectl apply -f https://download.elastic.co/downloads/eck/2.9.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.9.0/operator.yaml


# ClusterIssuer
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

# install prod
velero backup create clusterrole-1115 --include-resources clusterrole,clusterrolebinding
velero backup create rbac-1115 --include-namespaces prod  --include-resources serviceaccounts,secrets,roles,rolebindings
velero backup create svc-1115 --include-namespaces prod  --include-resources ingresses,services,configmaps

velero backup create cm-1116 --include-namespaces prod  --include-resources configmaps
velero backup create elasticsearch-1115 --include-namespaces eck,elastic-system,logging,obaservability
velero backup create ingress-updated --include-namespaces prod --include-resources ingresses

velero backup create cronjobs-1117 --include-namespaces prod --include-resources cronjobs
velero backup create hpa-1117 --include-namespaces prod --include-resources hpa
velero backup create monitoring-1117 --include-namespaces monitoring

# 多餘的, 不需要
velero backup create cert-1115 --include-namespaces prod  --include-resources certificate,certificaterequests,orders


velero backup create rabbitmq-11-02 --include-namespaces rabbitmq,rabbitmq-system

velero backup create monitoring-1106 --include-namespaces logging,monitoring,observability

velero backup create pvc-1106 --include-namespaces prod  --include-resources pvc
velero backup create deploy-1107 --include-namespaces prod  --include-resources deployments,daemonsets,hpa,cronjobs
velero backup create deploy-1108 --include-namespaces prod  --include-resources deployments,svc,hpa,cronjobs


velero restore create clusterrole --from-backup  clusterrole-1115
velero restore create rbac --from-backup  rbac-1115
velero restore create svc --from-backup svc-1115
velero restore create elasticsearch --from-backup elasticsearch-1115

velero restore create rabbitmq --from-backup rabbitmq-11-02  
velero restore create monitoring-1117 --from-backup monitoring-1117


velero restore create deploy-1108 --from-backup deploy-1108
velero restore create cm-1116 --from-backup cm-1116
velero restore create hpa-1117 --from-backup hpa-1117



velero schedule create monitoring --include-namespaces monitoring --schedule="@daily"  --ttl 2160h0m0s
velero schedule create observability --include-namespaces observability,logging --schedule="@daily"  --ttl 2160h0m0s
velero schedule create deployment --include-namespaces prod --include-resources deployments --schedule="@daily"  --ttl 2160h0m0s
velero schedule create service --include-namespaces prod --include-resources svc --schedule="@daily"  --ttl 2160h0m0s
velero schedule create ingress --include-namespaces prod --include-resources ingresses --schedule="@daily"  --ttl 2160h0m0s
velero schedule create cronjobs --include-namespaces prod --include-resources cronjobs --schedule="@daily"  --ttl 2160h0m0s
velero schedule create hpa --include-namespaces prod --include-resources hpa --schedule="@daily"  --ttl 2160h0m0s



## remove tls secrets
for p in $(kubectl get secrets -n $namespace | grep tls | awk '{print $1}');do kubectl delete secrets $p -n $namespace; done;

## create serviceaccount secrets
ns=('prod' 'logging' 'monitoring' 'observability' 'rabbitmq-system' 'rabbitmq' 'eck' 'elastic-system')
ns=('prod')

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


bash kubeconfig-convert.sh


# restore grafana
sudo grafana-backup save --config=/home/ubuntu/tgs-deployment/monitoring/staging/grafana-backup-restore/backup.json
sudo grafana-backup restore --config=grafana-restore.json  202311060654.tar.gz
sudo grafana-backup restore --config=grafana-restore-stack.json  202311070807.tar.gz


# nats Official
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm upgrade --install nats nats/nats -f values-nats.yaml -n prod

helm uninstall nats -n prod


# install rabbitmq

https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

## install krew
https://krew.sigs.k8s.io/docs/user-guide/setup/install/

kubectl krew install rabbitmq
kubectl rabbitmq install-cluster-operator


kubectl create ns rabbitmq
kubectl apply -f rabbitmq.yml
kubectl apply -f ingress.yml

kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_user_tags tgs administrator
kubectl -n rabbitmq exec mq-server-1 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-1 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-1 -- rabbitmqctl set_user_tags tgs administrator
kubectl -n rabbitmq exec mq-server-2 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-2 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-2 -- rabbitmqctl set_user_tags tgs administrator



# restart deploy
for p in $(kubectl get deploy -n prod | grep -v -E 'nats|pgpool' | awk '{print $1}');do kubectl rollout restart deploy $p -n prod ;done;

