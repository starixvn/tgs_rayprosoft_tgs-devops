#!/bin/bash
helm uninstall fluent-bit -n logging
helm uninstall log-center -n logging
helm uninstall ingress-nginx -n nginx-ingress
helm uninstall prometheus-stack -n monitoring 
kubectl delete -f k8s-installation/observability/jaeger-eck.yml
kubectl delete -f k8s-installation/observability/elasticsearch-eck-prod.yaml
kubectl delete -f k8s-installation/observability/kibana-eck-prod
kubectl delete -f k8s-installation/rabbitmq/rabbitmq.yaml