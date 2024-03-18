#!/bin/bash
export authority_data=$(kubectl config view --raw --minify -o json |  jq '."clusters" | first | .cluster."certificate-authority-data"')
export cluster_server=$(kubectl config view --raw --minify -o json |  jq '."clusters" | first | .cluster.server')
export current_context=$(kubectl config view --raw --minify -o json |  jq '."current-context"')
export namespace=prod
export account=editor
## 1.22 version
#export userTokenName=$(kubectl -n $namespace get sa $account_name -o=jsonpath='{.secrets[0].name}')
#export user_token=$(kubectl -n $namespace get secret/$userTokenName -o=go-template='{{.data.token}}' | base64 --decode)

## 1.26 version
### https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-service-account/
export user_token=$(kubectl -n $namespace get secret/${account}-secret -o=go-template='{{.data.token}}' | base64 --decode)

envsubst < kubeconfig > ~/.kube/config2
