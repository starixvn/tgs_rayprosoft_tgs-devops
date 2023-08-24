#!/bin/bash
## install rabbitmq
# https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

## install krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/

kubectl krew install rabbitmq
kubectl rabbitmq install-cluster-operator

kubectl create ns rabbitmq
kubectl apply -f rabbitmq.yaml
kubectl apply -f ingress.yaml

sleep 60
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl add_vhost /tgs/prod
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_permissions -p "/tgs/prod" "tgs" '.*' '.*' '.*'
kubectl -n rabbitmq exec mq-server-0 -- rabbitmqctl set_user_tags tgs administrator