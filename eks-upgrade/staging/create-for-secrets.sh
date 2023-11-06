#!/bin/bash
export namespace=staging

## remove tls secrets
for p in $(kubectl get secrets -n $namespace | grep tls | awk '{print $1}');do kubectl delete secrets $p -n $namespace; done;

for p in $(kubectl get sa -n $namespace | awk '{print $1}');do \
  kubectl apply -o yaml -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: $p
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "$p"
EOF
done;
