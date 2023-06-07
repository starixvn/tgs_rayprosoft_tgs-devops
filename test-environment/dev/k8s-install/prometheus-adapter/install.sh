#!/bin/bash
repo=prometheus-adapter
version=$(helm search repo $repo | grep $repo | awk '{print $2}')
helm pull prometheus-community/$repo --version $version
tar -xzvf $repo-$versio.tgz
cd prometheus-adapter && sed -i 's/prometheus.default.svc/prometheus-stack-kube-prom-prometheus/g' values.yaml
helm install prometheus-adapter prometheus-community/prometheus-adapter -f values.yaml -n monitoring

kubectl get apiservices|grep prometheus
