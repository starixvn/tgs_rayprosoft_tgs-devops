#!/bin/bash
repo=prometheus-adapter
version=$(helm search repo $repo | grep $repo | awk '{print $2}')
helm pull prometheus-community/$repo --version $version
tar -xzvf $repo-$version.tgz
cd prometheus-adapter && sed -i 's/prometheus.default.svc/prometheus-stack-kube-prom-prometheus/g' values.yaml
helm install prometheus-adapter prometheus-community/prometheus-adapter -f values.yaml -n monitoring

kubectl get apiservices|grep prometheus

# 可以做 hpa 的 metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 |jq  
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq | grep "\"name\"" 
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1| jq . |grep "http_request"


# 執行壓測
while true ; do sleep 1s && curl `kubectl get svc|grep sample-app|awk '{print $3}'` ; done


# 可以透過下面 找到 該 pod 的 全部 metrics
{pod="email-api-7c9c955c6d-4qqqk"}
