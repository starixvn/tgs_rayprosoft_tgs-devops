export account=tgs-build
export namespace=staging

cat << EOF | kubectl apply -n $namespace -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${account}
  namespace: ${namespace}
rules:
- apiGroups:
  - '*'
  resources:
  - deployments
  - service
  - configmap
  - secrets
  - ingress
  - serviceaccount
  verbs:
  - get
  - patch
  - list
  - watch
  - create
  - update
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
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${account}
  namespace: $namespace
---
apiVersion: v1
kind: Secret
metadata:
  name: ${account}-token
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "${account}"
EOF