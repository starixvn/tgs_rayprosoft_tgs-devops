export account=tgs-build
export namespace=dev

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
  - services
  - configmaps
  - secrets
  - ingresses
  - serviceaccounts
  - roles
  - rolebindings
  - cronjobs
  - jobs
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
cat << EOF | kubectl apply -n $namespace -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${account}
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: "${account}"
type: kubernetes.io/service-account-token
EOF