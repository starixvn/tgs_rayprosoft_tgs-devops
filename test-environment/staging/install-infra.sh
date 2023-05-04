#!/bin/bash
AddImagePullSecrets(){
	_namespace=$1
	_deploy_or_sts=$2
	_name=$3
	
	kubectl -n ${_namespace} get ${_deploy_or_sts} ${_name} -o yaml > ${_name}.yaml
	sed -i 's/dnsPolicy: ClusterFirst/dnsPolicy: ClusterFirst\n      imagePullSecrets:\n      - name: dockerhub/g' ${_name}.yaml
	kubectl delete -f ${_name}.yaml
	sleep 2
	kubectl apply -f ${_name}.yaml
	sudo rm -rf ${_name}.yaml
}

# cert-manager
## https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
sleep 20
kubectl apply -f k8s-installation/cluster-issuer.yml
kubectl apply -f k8s-installation/dockerhub.yml

# metric-server 
## https://github.com/kubernetes-sigs/metrics-server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# reloader 
## https://github.com/stakater/Reloader

kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml


# ingress-controller
## for class load balancer
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create ns ingress-nginx

helm -n ingress-nginx install nginx-ingress ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"


# rabbitmq
## https://www.rabbitmq.com/kubernetes/operator/operator-overview.html
## https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

# AddImagePullSecrets rabbitmq-system deploy rabbitmq-cluster-operator 

kubectl create ns rabbitmq

# kubectl delete -f k8s-installation/rabbitmq/rabbitmq.yaml
kubectl apply -f k8s-installation/rabbitmq/rabbitmq.yaml
sleep 20
kubectl apply -f k8s-installation/rabbitmq/ingress.yaml

AddImagePullSecrets rabbitmq sts mq-server

# kubectl exec -it  mq-server-0 /bin/bash -n rabbitmq
# rabbitmqctl add_vhost /tgs/staging
# rabbitmqctl set_permissions -p "/tgs/staging" "tgs" '.*' '.*' '.*'
# rabbitmqctl set_user_tags tgs administrator



# elasticsearch
## https://github.com/elastic/helm-charts
helm repo add elastic https://helm.elastic.co
kubectl create ns observability
helm upgrade -i elasticsearch k8s-installation/elasticsearch/ -f k8s-installation/elasticsearch/values.yaml -n observability


# helm install  elasticsearch .  -f values.yaml -n observability2
# helm uninstall elasticsearch -n observability
### helm template elasticsearch k8s-installation/elasticsearch/ -f k8s-installation/elasticsearch/values.yaml  -n observability
### helm uninstall elasticsearch -n observability


# kibana
helm repo add elastic https://helm.elastic.co
helm repo update
helm upgrade --install kibana k8s-installation/kibana/ --set imageTag=8.5.1 -f k8s-installation/kibana/values.yaml -n observability


# jaeger
## https://www.jaegertracing.io/docs/1.42/operator/#production-strategy
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.42.0/jaeger-operator.yaml -n observability2
sleep 30
kubectl apply -f k8s-installation/jaeger/
kubectl apply -f k8s-installation/jaeger/otel/


# fluent-bit
# REF: https://docs.fluentbit.io/manual/installation/kubernetes#installation
kubectl create namespace logging
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm upgrade -i fluent-bit fluent/fluent-bit -f k8s-installation/fluentbit/edge-values.yaml -n logging
helm upgrade -i log-center fluent/fluent-bit -f k8s-installation/fluentbit/center-values.yaml --set replicaCount=3 -n logging

### 安裝完成後使用 kubectl edit ds fluent-bit -n logging 修改 forward port，增加hostPort: 24224

kubectl get ds fluent-bit -n logging -o yaml > fluent-bit.yaml
sed -i 's/containerPort: 24224/containerPort: 24224\n          hostPort: 24224/g' fluent-bit.yaml
kubectl delete -f fluent-bit.yaml
sleep 2
kubectl apply -f fluent-bit.yaml
  
  
# prometheus 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create ns monitoring
helm upgrade -i prometheus prometheus-community/prometheus -f k8s-installation/values-prometheus.yaml -n monitoring
# helm uninstall prometheus -n monitoring
### helm template prometheus prometheus-community/prometheus -f values-prometheus.yaml -n monitoring
### helm uninstall prometheus -n monitoring
### https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

# grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install grafana grafana/grafana -f k8s-installation/values-grafana.yaml --set image.tag=9.2.6 -n monitoring
### helm template grafana grafana/grafana -f values-grafana.yaml --set image.tag=9.2.6,ingress.hosts[0]=dev2-grafana.rpgp.cc -n monitoring
### helm uninstall grafana -n monitoring

## https://hub.docker.com/r/grafana/grafana/tags

# kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


# nats
kubectl create ns staging
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n staging

#AddImagePullSecrets staging sts nats
#AddImagePullSecrets staging deploy nats-box

## helm template nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3,imagePullSecrets[0]=dockerhub -n staging

## helm upgrade --install nats nats/nats -f nats-values.yaml -n dev
## helm uninstall nats -n staging

# redis, redis exporter
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade -i redis bitnami/redis --set password=1qaz2wsx,auth.enabled=false,metrics.enabled=true -n staging
# helm uninstall redis -n staging

# mongodb,  and exporter
helm  upgrade -i mongodb bitnami/mongodb \
	--set auth.rootPassword=1qaz2wsx \
	--set auth.enabled=false \
	--set metrics.enabled=true \
	--set image.tag=5.0.9-debian-11-r3 -n staging

# helm uninstall mongodb -n staging

kubectl apply -f _pgpool_staging2


## rabbitmq after action
kubectl -n rabbitmq exec -it  mq-server-0 -- rabbitmqctl add_vhost /tgs/staging
kubectl -n rabbitmq exec -it  mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/staging" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec -it  mq-server-0 -- rabbitmqctl set_user_tags tgs administrator



#kubectl patch pvc persistence-mq-server-0 -p '{"metadata":{"finalizers":null}}' -n rabbitmq

#kubectl patch pv pvc-481b34ba-69cf-412b-b1a6-742eac299f62 -p '{"metadata":{"finalizers":null}}'


