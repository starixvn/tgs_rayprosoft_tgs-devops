#!/bin/bash
master_url=k8s2-master-1

kubectl -n monitoring create secret generic etcd-certs \
--from-file=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--from-file=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--from-file=/etc/kubernetes/pki/etcd/ca.crt 

export TOKEN=`kubectl -n monitoring exec -it prometheus-prometheus-stack-kube-prom-prometheus-0 -c prometheus -- cat /var/run/secrets/kubernetes.io/serviceaccount/token`

curl -k https://$master_url:10250/metrics --header "Authorization: Bearer $TOKEN"


kubectl -n monitoring exec -it prometheus-prometheus-stack-kube-prom-prometheus-0 -- ls /etc/prometheus/secrets/etcd-certs


helm upgrade --reuse-values -f values.yaml prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring

helm upgrade --install -f values.yaml prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring


kubectl -n monitoring edit servicemonitor prometheus-stack-kube-prom-kube-etcd
/etc/prometheus/secrets/etcd-certs



# fix etcd
mv /etc/kubernetes/manifests/etcd.yaml ./
sleep 3
sed -i 's/listen-metrics-urls=http://127.0.0.1:2381/listen-metrics-urls=http://0.0.0.0:2381/g' etcd.yaml
mv etcd.yaml /etc/kubernetes/manifests/

# fix kube-scheduler
mv /etc/kubernetes/manifests/kube-scheduler.yaml ./
sleep 3
sed -i 's/bind-address=127.0.0.1/bind-address=0.0.0.0/g' kube-scheduler.yaml
mv kube-scheduler.yaml /etc/kubernetes/manifests/

# fix kube-controller-manager
mv /etc/kubernetes/manifests/kube-controller-manager.yaml ./
sleep 3
sed -i 's/bind-address=127.0.0.1/bind-address=0.0.0.0/g' kube-controller-manager.yaml
mv kube-controller-manager.yaml /etc/kubernetes/manifests/

# fix kube-proxy
kubectl -n kube-system get configmap kube-proxy -o yaml > cm-kube-proxy.yaml
sed -i 's/metricsBindAddress: ""/metricsBindAddress: "0.0.0.0"/g' cm-kube-proxy.yaml
kubectl apply -f cm-kube-proxy.yaml
kubectl -n kube-system delete pod -l k8s-app=kube-proxy
rm cm-kube-proxy.yaml