#!/bin/bash
aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-staging2

kubectl create ns staging

helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n staging

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis --set password=1qaz2wsx,auth.enabled=false,metrics.enabled=true -n staging


helm install mongodb bitnami/mongodb --set auth.rootPassword=1qaz2wsx,auth.enabled=false,metrics.enabled=true,image.tag=5.0.9-debian-11-r3 -n staging

helm install mongodb-express cowboysysop/mongo-express  --set mongodbEnableAdmin=true,mongodbAdminPassword=1qaz2wsx,ingress.enabled=true,ingress.hosts[0].host=stg2-mongodb-express.rpgp.cc,ingress.hosts[0].paths[0]=/ -n staging

