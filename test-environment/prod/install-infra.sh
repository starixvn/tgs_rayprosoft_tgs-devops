#!/bin/bash
# cert-manager
## https://cert-manager.io/docs/installation/
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
sleep 20
kubectl apply -f ./cluster-issuer.yml

# metric-server 
## https://github.com/kubernetes-sigs/metrics-server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# reloader 
## https://github.com/stakater/Reloader

kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml


# ingress-controller
## for class load balancer
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx

helm -n ingress-nginx install nginx-ingress ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"

## for delete
# kubectl patch pvc persistence-mq-server-0 -p '{"metadata":{"finalizers":null}}' -n rabbitmq
# kubectl patch pv pvc-481b34ba-69cf-412b-b1a6-742eac299f62 -p '{"metadata":{"finalizers":null}}'


