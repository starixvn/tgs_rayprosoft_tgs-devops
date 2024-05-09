#!/bin/bash
export account=tgs-admin
export namespace=dev

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
  name: ${account}
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "${account}"
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${account}
  namespace: ${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${account}
subjects:
- kind: ServiceAccount
  name: ${account}
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${account}
  namespace: ${namespace}
rules:
- apiGroups:
  - ''
  resources:
  - '*'
  verbs:
  - get
  - patch
  - list
  - watch
  - create
  - update
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${account}
  namespace: ${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${account}
subjects:
- kind: ServiceAccount
  name: ${account}
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${account}
rules:
- apiGroups:
  - ''
  resources:
  - '*'
  verbs:
  - get
  - patch
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view-all
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${account}-view-all
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
  name: view-node
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