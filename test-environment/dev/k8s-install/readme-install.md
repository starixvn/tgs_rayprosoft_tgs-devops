# Install bash-completion
## https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/

apt-get install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exec bash
## exit 登出再登入


# helm 
https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


### calico
## https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises

curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
sed -i 's/# - name: CALICO_IPV4POOL_CIDR/- name: CALICO_IPV4POOL_CIDR\n              value: "172.16.0.0\/16"/g'  calico.yaml
kubectl apply -f calico.yaml

### ingress

#REF: https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters

#REF: https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
helm -n ingress-nginx upgrade -i nginx-ingress ingress-nginx/ingress-nginx -f values-ingress-controller.yaml

*** 修改 nginx.conf 的 http, https port
	
### cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml


# metric-server 
https://github.com/kubernetes-sigs/metrics-server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl edit deploy  metrics-server -n kube-system
kubectl get deploy metrics-server -n kube-system -o yaml > metrics-server.yaml
sed -i 's/kubelet-use-node-status-port/kubelet-use-node-status-port\n        - --kubelet-insecure-tls/g'  metrics-server.yaml
## deploy args 要加上 - --kubelet-insecure-tls
kubectl apply -f metrics-server.yaml

# reloader 
https://github.com/stakater/Reloader

kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml


# nfs provisioner
(
apt update
apt install nfs-common -y
mkdir -p /nfsshare
mount -t nfs 192.168.50.111:/nfsshare /nfsshare
sed -i '$a192.168.50.111:/nfsshare /nfsshare nfs defaults 0 0' /etc/fstab
ls /nfsshare
)

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
  
helm repo update

helm install nfs-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=192.168.50.111 \
  --set nfs.path=/nfsshare \
  --set storageClass.name=nfs-provisioner
  
# clone tgs-devops repository
 
git clone https://gitlab.com/rayprosoft/tgs-devops.git
kubectl apply -f tgs-devops/dev-machines/k8s-installation/cluster-issuer.ym

# rabbitmq
## https://www.rabbitmq.com/kubernetes/operator/operator-overview.html
## https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

## go to k8s-installation/rabbitmq
kubectl create ns rabbitmq
kubectl apply -f rabbitmq.yaml
kubectl apply -f ingress.yaml

https://blog.csdn.net/qq_24095055/article/details/97001679

kubectl exec -it  mq-server-0 /bin/bash -n rabbitmq

rabbitmqctl add_user tgs TgsP@ssw0rd

rabbitmqctl add_vhost /tgs/dev
rabbitmqctl add_vhost /tgs/staging
rabbitmqctl add_vhost /tgs/prod

rabbitmqctl set_permissions -p "/tgs/dev" "tgs" '.*' '.*' '.*'
rabbitmqctl set_permissions -p "/tgs/staging" "tgs" '.*' '.*' '.*'
rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
rabbitmqctl set_user_tags tgs administrator

https://rabbitmq.rpgp.cc/

## changing node types 
## 可忽略
kubectl exec -it mq-server-0 /bin/bash -n rabbitmq
rabbitmqctl cluster_status
rabbitmqctl change_cluster_node_type disc
rabbitmqctl change_cluster_node_type ram
rabbitmqctl stop_app
rabbitmqctl start_app


# elasticsearch
https://github.com/elastic/helm-charts
helm repo add elastic https://helm.elastic.co
kubectl create ns observability
cd elasticsearch
helm upgrade -i elasticsearch . -f values.yaml -n observability
helm template elasticsearch . -f values.yaml  -n observability
helm uninstall elasticsearch -n observability


# jaeger
## https://www.jaegertracing.io/docs/1.42/operator/#production-strategy
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.42.0/jaeger-operator.yaml -n observability


kubectl apply -f jaeger/rbac-jaeger.yaml
kubectl apply -f jaeger/jaeger.yaml
kubectl apply -f jaeger/otel/

# kibana
helm repo add elastic https://helm.elastic.co
helm repo update
helm upgrade --install kibana . --set imageTag=8.5.1 -f values.yaml -n observability


# nats Official
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --set cluster.enabled=true,auth.enabled=false -n dev
helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n dev
helm upgrade --install nats nats/nats -f values-nats.yaml -n dev

helm uninstall nats -n dev

### https://github.com/nats-io/k8s/tree/master/helm/charts/stan

# redis, redis exporter
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis --set password=1qaz2wsx,metrics.enabled=true,master.disableCommands=["FLUSHDB"] -n dev

helm upgrade -i redis bitnami/redis --set global.storageClass=nfs-provisioner,global.redis.password=1qaz2wsx,metrics.enabled=true,auth.enabled=false -n dev
helm uninstall redis -n dev

redis-metrics:9121/metrics 
https://github.com/bitnami/charts/tree/master/bitnami/redis/#installing-the-chart


# redisinsight

helm install redisinsight ./redisinsight -f ./redisinsight/values.yaml -n dev
https://docs.redislabs.com/latest/ri/installing/install-k8s/
http://dev-redisinsight.rpgp.cc/


# mongodb,  and exporter
helm install mongodb bitnami/mongodb \
	--set global.storageClass=nfs-provisioner \
	--set auth.rootPassword=1qaz2wsx \
	--set auth.enabled=false \
	--set metrics.enabled=true \
	--set image.tag=5.0.9-debian-11-r3 -n dev

mongodb-metrics:9216/metrics 
https://github.com/bitnami/charts/tree/master/bitnami/mongodb#installing-the-chart

mongodb 6.0 版本 更新很大
https://www.mongodb.com/docs/v6.0/release-notes/6.0-compatibility/#legacy-opcodes-removed

helm install mongodb bitnami/mongodb --set auth.rootPassword=1qaz2wsx,auth.enabled=false,metrics.enabled=true,image.tag=5.0.9-debian-11-r3 -n staging
helm uninstall mongodb -n dev
	
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
helm upgrade -i mongodb-express cowboysysop/mongo-express  --set mongodbEnableAdmin=true,mongodbAdminPassword=1qaz2wsx,ingress.enabled=true,ingress.hosts[0].host=mongodb-express.rpgp.cc,ingress.hosts[0].paths[0]=/,ingress.ingressClassName=nginx -n dev
http://mongodb-express.rpgp.cc
https://artifacthub.io/packages/helm/cowboysysop/mongo-express


# fluent-bit
改用helm upgrade -i 安裝

kubectl create namespace logging

REF: https://docs.fluentbit.io/manual/installation/kubernetes#installation

helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

cd fluentbit/

helm upgrade -i fluent-bit fluent/fluent-bit -f edge-values.yaml -n logging
helm upgrade -i log-center fluent/fluent-bit -f center-values.yaml --set replicaCount=3 -n logging

helm template fluent-bit fluent/fluent-bit -f edge-values.yaml -n logging
helm template log-center fluent/fluent-bit -f center-values.yaml --set replicaCount=3 -n logging


再重新執行helm upgrade指令

安裝完成後使用 kubectl edit ds fluent-bit -n logging 修改 forward port，增加hostPort: 24224

# prometheus 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create ns monitoring

helm upgrade -i prometheus prometheus-community/prometheus --set server.ingress.hosts[0]=dev2-prometheus.rpgp.cc -f values-prometheus.yaml -n monitoring

helm template prometheus prometheus-community/prometheus -f values-prometheus.yaml -n monitoring

helm uninstall prometheus -n monitoring

https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

# grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install grafana grafana/grafana -f values-grafana.yaml --set image.tag=9.2.6,ingress.hosts[0]=dev2-grafana.rpgp.cc -n monitoring
helm template grafana grafana/grafana -f values-grafana.yaml --set image.tag=9.2.6,ingress.hosts[0]=dev2-grafana.rpgp.cc -n monitoring
helm uninstall grafana -n monitoring

https://hub.docker.com/r/grafana/grafana/tags

kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


# minio 
kubectl create ns minio
helm upgrade --install  minio bitnami/minio -f values-minio.yaml  --set auth.rootPassword=B4pCvrXfaz  -n minio

export ROOT_USER=$(kubectl get secret --namespace minio minio -o jsonpath="{.data.root-user}" | base64 -d)
export ROOT_PASSWORD=$(kubectl get secret --namespace minio minio -o jsonpath="{.data.root-password}" | base64 -d)

go to https://minio.rpgp.cc/
admin/B4pCvrXfaz
新增 Buckets : tgs-project & tgs-secret
新增 Identity/Users: 
	aws-accessKeyId: 1SVW99PHVVBJRELWTSJN
	aws-secretAccessKey: 2+suqoLHk1TUPkjTI6T02RIDZn0xqQTy85F8Pjco
  

# consul 
## https://github.com/hashicorp/consul-helm/blob/master/values.yaml

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/consul
helm install consul hashicorp/consul -f values-consul.yaml --create-namespace -n consul
helm uninstall consul -n consul
