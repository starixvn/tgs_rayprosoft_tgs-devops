#!/bin/bash
# Install Elastic Cloud on Kubernetes
# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html

kubectl create -f https://download.elastic.co/downloads/eck/2.9.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.9.0/operator.yaml
kubectl create ns eck
kubectl apply -f elasticsearch-eck-prod.yaml
kubectl apply -f kibana-eck-prod.yaml

# Install Jaeger - operator
# https://www.jaegertracing.io/docs/1.47/operator/
kubectl create namespace observability 
kubectl apply -f jaeger-rbac.yaml
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.47.0/jaeger-operator.yaml -n observability

# Install OTEL
kubectl apply -f otel-configmap.yaml
kubectl apply -f otel-collector.yaml

# Install FluentBit
kubectl create namespace logging
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
helm upgrade -i fluent-bit fluent/fluent-bit -f fluentbit-edge-values.yaml -n logging
helm upgrade -i log-center fluent/fluent-bit -f fluentbit-center-values.yaml --set replicaCount=1 -n logging

### 安裝完成後使用 kubectl edit ds fluent-bit -n logging 修改 forward port，增加hostPort: 24224

kubectl get ds fluent-bit -n logging -o yaml > fluent-bit.yaml
sed -i 's/containerPort: 24224/containerPort: 24224\n          hostPort: 24224/g' fluent-bit.yaml
kubectl delete -f fluent-bit.yaml
sleep 2
kubectl apply -f fluent-bit.yaml

# Install Jaege
sleep 10
kubectl apply -f jaeger-eck.yml
rm -rf fluent-bit.yaml