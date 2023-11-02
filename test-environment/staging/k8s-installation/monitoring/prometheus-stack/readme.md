# REF: https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml

kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm upgrade -i prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring
# helm template prometheus-stack prometheus-community/kube-prometheus-stack --version 46.6.0 -f values.yaml -n monitoring

helm uninstall prometheus-stack -n monitoring

helm upgrade --reuse-values -f values.yaml prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring

kubectl get svc prometheus-stack-kube-prom-prometheus -n monitoring -o yaml > svc-prometheus.yaml
sed -i 's/type: ClusterIP/type: NodePort/g' svc-prometheus.yaml
sed -i 's/protocol: TCP/protocol: TCP\n    nodePort: 30370/g' svc-prometheus.yaml
kubectl apply -f svc-prometheus.yaml


grafana
admin/prom-operator

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/dev/metrics"
