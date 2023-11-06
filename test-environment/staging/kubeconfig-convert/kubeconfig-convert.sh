#!/bin/bash
export authority_data=$(kubectl config view --raw --minify -o json |  jq '."clusters" | first | .cluster."certificate-authority-data"')
export cluster_server=$(kubectl config view --raw --minify -o json |  jq '."clusters" | first | .cluster.server')
export current_context=$(kubectl config view --raw --minify -o json |  jq '."current-context"')
export namespace=staging
export account_name=raypro-staging-build
## 1.22 version
#export userTokenName=$(kubectl -n $namespace get sa $account_name -o=jsonpath='{.secrets[0].name}')
#export user_token=$(kubectl -n $namespace get secret/$userTokenName -o=go-template='{{.data.token}}' | base64 --decode)

## 1.26 version
### https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-service-account/
export user_token=$(kubectl -n $namespace get secret/raypro-staging-build -o=go-template='{{.data.token}}' | base64 --decode)

envsubst < kubeconfig > ~/.kube/config2




## https://medium.com/@gowthamshankar09/how-to-create-serviceaccount-secret-in-kubernetes-1-24-36a61bdb73ad:q