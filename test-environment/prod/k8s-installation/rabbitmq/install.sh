#!/bin/bash
## install rabbitmq
# https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

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

kubectl krew install rabbitmq
kubectl rabbitmq install-cluster-operator

kubectl create ns rabbitmq
kubectl apply -f rabbitmq.yaml
kubectl apply -f ingress.yaml

sleep 30
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_user_tags tgs administrator