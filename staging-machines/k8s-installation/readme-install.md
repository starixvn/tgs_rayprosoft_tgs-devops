# Install bash-completion
## https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/

apt-get install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exec bash
## exit 登出再登入

# cert-manager
https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml


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

https://stg2-rabbitmq.rpgp.cc/

## changing node types 

kubectl exec -it mq-server-0 /bin/bash -n rabbitmq
rabbitmqctl cluster_status
rabbitmqctl change_cluster_node_type disc
rabbitmqctl change_cluster_node_type ram
rabbitmqctl stop_app
rabbitmqctl start_app


# elasticsearch
## https://github.com/elastic/helm-charts
helm repo add elastic https://helm.elastic.co
kubectl create ns observability
cd elasticsearch
helm upgrade -i elasticsearch . -f values.yaml -n observability
helm template elasticsearch . -f values.yaml  -n observability
helm uninstall elasticsearch -n observability

# kibana
helm repo add elastic https://helm.elastic.co
helm repo update
helm upgrade --install kibana --set imageTag=8.5.1 -f values.yaml -n observability


# jaeger
## https://www.jaegertracing.io/docs/1.42/operator/#production-strategy
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.42.0/jaeger-operator.yaml -n observability

kubectl apply -f jaeger/rbac-jaeger.yaml.yml
kubectl apply -f jaeger/jaeger.yaml.yml
kubectl apply -f jaeger/otel/

# nats Official
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --set cluster.enabled=true,auth.enabled=false -n dev
helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n dev
helm upgrade --install nats nats/nats -f nats-values.yaml -n dev

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
