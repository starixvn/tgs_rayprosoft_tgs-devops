#!/bin/bash

# rabbitmq
## https://www.rabbitmq.com/kubernetes/operator/operator-overview.html
## https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

kubectl patch pv <pv_name> -p '{"metadata":{"finalizers":null}}'
kubectl delete pv <pv_name> --grace-period=0 --force 

==> AccessDenied: Not authorized to perform AudoScaling:DescribeTags
==> AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity


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
helm upgrade --install kibana . --set imageTag=8.5.1 -f values.yaml -n observability


# jaeger
## https://www.jaegertracing.io/docs/1.42/operator/#production-strategy
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.42.0/jaeger-operator.yaml -n observability

kubectl apply -f jaeger/rbac-jaeger.yaml.yml
kubectl apply -f jaeger/jaeger.yaml.yml
kubectl apply -f jaeger/otel/


# prometheus 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create ns monitoring

helm upgrade -i prometheus prometheus-community/prometheus -f values-prometheus.yaml -n monitoring

helm template prometheus prometheus-community/prometheus -f values-prometheus.yaml -n monitoring

helm uninstall prometheus -n monitoring

https://kubernetes.github.io/ingress-nginx/examples/auth/basic/


# grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install grafana grafana/grafana -f values-grafana.yaml --set image.tag=9.2.6 -n monitoring
helm template grafana grafana/grafana -f values-grafana.yaml --set image.tag=9.2.6,ingress.hosts[0]=dev2-grafana.rpgp.cc -n monitoring
helm uninstall grafana -n monitoring

https://hub.docker.com/r/grafana/grafana/tags

kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo