#!/bin/bash
## remove tls secrets
for p in $(kubectl get secrets -n $namespace | grep tls | awk '{print $1}');do kubectl delete secrets $p -n $namespace; done;

ns=('prod' 'logging' 'monitoring' 'observability','eck','elastic-system')

for n in ${ns[@]}; do
  for p in $(kubectl get sa -n $n | awk '{print $1}');do 
    kubectl apply -o yaml -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: $p
  namespace: $n
  annotations:
    kubernetes.io/service-account.name: "$p"
EOF
  done;
done;
