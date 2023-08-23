#!/bin/bash
master_url=k8s2-master-1

export TOKEN=`kubectl -n monitoring exec -it prometheus-prometheus-stack-kube-prom-prometheus-0 -c prometheus -- cat /var/run/secrets/kubernetes.io/serviceaccount/token`

curl -k https://$master_url:10250/metrics --header "Authorization: Bearer $TOKEN"


kubectl -n monitoring exec -it prometheus-prometheus-stack-kube-prom-prometheus-0 -- ls /etc/prometheus/secrets/etcd-certs


helm upgrade --reuse-values -f values.yaml prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring

helm upgrade --install -f values.yaml prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring


kubectl -n monitoring edit servicemonitor prometheus-stack-kube-prom-kube-etcd
/etc/prometheus/secrets/etcd-certs
