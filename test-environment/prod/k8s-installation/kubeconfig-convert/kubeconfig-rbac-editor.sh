#!/bin/bash
export account=editor
export namespace=prod

kubectl -n $namespace create serviceaccount $account

cat << EOF | kubectl apply -n $namespace -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $account
  namespace: $namespace
automountServiceAccountToken: false
---
apiVersion: v1
kind: Secret
metadata:
  name: ${account}-token
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "${account}"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${account}
  namespace: ${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: ${account}
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: edit-${namespace}
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "watch", "list", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${account}-edit-${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: ${account}
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: edit-node
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${account}-view-node
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view-node
subjects:
- kind: ServiceAccount
  name: ${account}
  namespace: ${namespace}
EOF


## 1.26 version
### https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-service-account/
kubectl create token $account -n $namespace

cat << EOF | kubectl apply -n $namespace -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${account}-secret
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: ${account}
type: kubernetes.io/service-account-token
EOF