# update kubeconfig

cd tgs-devops/eks-upgrade/staging

aws eks update-kubeconfig --name tgs-k8s-staging

bash install-autoscaler.sh
# install csi-controller
# install node-terminate-handler
# install velero 
export namespace=staging
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

# ingress-controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
helm upgrade -i nginx ingress-nginx/ingress-nginx -f values-ingress-controller.yaml -n ingress-nginx

# cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml


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
velero backup create clusterrole-1106 --include-resources clusterrole,clusterrolebinding
velero backup create rbac-1106 --include-namespaces staging  --include-resources serviceaccounts,secrets,roles,rolebindings
velero backup create rabbitmq-11-02 --include-namespaces rabbitmq,rabbitmq-system

velero backup create monitoring-11-06 --include-namespaces logging,monitoring,observability
velero backup create svc-1106 --include-namespaces staging  --include-resources ingresses,services,configmaps
velero backup create pvc-1106 --include-namespaces staging  --include-resources pvc
velero backup create deploy-1107 --include-namespaces staging  --include-resources deployments,daemonsets,hpa,cronjobs
velero backup create deploy-1108 --include-namespaces staging  --include-resources deployments,svc,hpa,cronjobs




velero restore create clusterrole --from-backup  clusterrole-1106
velero restore create rbac --from-backup  rbac-1106
velero restore create rabbitmq --from-backup rabbitmq-11-02  
velero restore create monitoring --from-backup monitoring-11-06 
velero restore create svc --from-backup svc-1107

velero restore create deploy --from-backup deploy-1107



## remove tls secrets
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


bash kubeconfig-convert.sh



# restore grafana
sudo grafana-backup save --config=/home/ubuntu/tgs-deployment/monitoring/staging/grafana-backup-restore/backup.json
sudo grafana-backup restore --config=grafana-restore.json  202311060654.tar.gz



# nats Official
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm upgrade --install nats nats/nats -f values-nats.yaml -n staging


### https://github.com/nats-io/k8s/tree/master/helm/charts/stan

# redis, redis exporter
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade -i redis bitnami/redis -f values-redis.yaml -n staging


redis-metrics:9121/metrics 
https://github.com/bitnami/charts/tree/master/bitnami/redis/#installing-the-chart


# redisinsight

helm upgrade -i redisinsight ./redisinsight -f ./redisinsight/values.yaml -n staging
https://docs.redislabs.com/latest/ri/installing/install-k8s/
http://dev-redisinsight.rpgp.cc/


# mongodb,  and exporter
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade -i mongodb bitnami/mongodb -f values-mongo.yaml -n staging
	
go to mongodb pods 
mongo
use admin
db.createUser(
    {
        user:"root",
        pwd:"1qaz2wsx",
        roles:[
            {role:"dbOwner", db:"admin"}
        ]
    }
)

# mongodb express
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm repo update
helm upgrade -i mongodb-express cowboysysop/mongo-express -f values-mongo-express.yaml -n staging
# http://stg-mongodb-express.rpgp.cc
# https://artifacthub.io/packages/helm/cowboysysop/mongo-express



# fix rabbitmq setting
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl add_vhost /tgs/staging
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/staging" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_user_tags tgs administrator
