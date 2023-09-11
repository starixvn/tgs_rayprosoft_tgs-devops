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

helm -n ingress-nginx upgrade -i nginx-ingress ingress-nginx/ingress-nginx -f values-nginx-ingress-conroller.yaml --set controller.replicaCount=3


## for delete
# kubectl patch pvc persistence-mq-server-0 -p '{"metadata":{"finalizers":null}}' -n rabbitmq
# kubectl patch pv pvc-481b34ba-69cf-412b-b1a6-742eac299f62 -p '{"metadata":{"finalizers":null}}'

kubectl apply -f cluster-issuer.yml


# install prometheus-stack
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack -f values-prometheus-stack.yaml -n monitoring


## install krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# install rabbitmq
# https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
kubectl krew install rabbitmq
kubectl rabbitmq install-cluster-operator

kubectl create ns rabbitmq
kubectl apply -f k8s-installation/rabbitmq/rabbitmq.yaml
kubectl apply -f k8s-installation/rabbitmq/ingress.yaml

sleep 30
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_user_tags tgs administrator

# nats Official
kubectl create ns prod
kubectl apply -f ./tgs-services/

# helm repo add nats https://nats-io.github.io/k8s/helm/charts/
# helm upgrade --install nats nats/nats -f values-nats.yaml -n prod

# velero
wget https://github.com/vmware-tanzu/velero/releases/download/v1.8.1/velero-v1.8.1-linux-amd64.tar.gz
tar zxvf velero-v1.8.1-linux-amd64.tar.gz
cp velero-v1.8.1-linux-amd64/velero /usr/local/bin
cat <<EOF | sudo tee ~/.credentials-velero
[default]
aws_access_key_id=AKIAQ4KFUNHMUZU6QD2V
aws_secret_access_key=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
EOF

export BUCKET=tgs-prod-backup
export REGION=ap-east-1
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.4.0 \
  --bucket $BUCKET \
  --backup-location-config region=$REGION \
  --snapshot-location-config region=$REGION \
  --secret-file ./.credentials-velero

 velero restore create test1 --from-backup prod-k8s-090803 