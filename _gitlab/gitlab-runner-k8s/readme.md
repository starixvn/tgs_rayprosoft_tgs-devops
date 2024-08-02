# gitlab-runner install k8s
https://gitlab.cn/blog/2021/12/09/runner-k8s/

https://chatgpt.com/share/bd4520e8-47e8-4d2e-a35f-a98fbfb91b73

https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/values.yaml


## 前置作業
```
helm repo add gitlab https://charts.gitlab.io
kubectl create ns gitlab-runner

## 已廢棄 kubeconfig
kubectl create secret generic kubeconfig --from-file=/home/ubuntu/.kube/config -n gitlab-runner
kubectl delete secrets kubeconfig  -n gitlab-runner
kubectl create secret generic kubeconfig --from-file=/root/kubeconfig -n gitlab-runner

```
## values.yaml  kubeconfig version (已廢棄)
```
gitlabUrl: https://gitlab.com/
runnerRegistrationToken: "$token"
replicas: 3
concurrency: 3
rbac:
  create: true
  generatedServiceAccountName: "gitlab-runner"
  rules:
    - resources: ["secrets", "pods", "pods/exec", "pods/attach"]
      verbs: ["get", "delete", "create", "update"]
serviceAccount:
  create: true
volumeMounts:
  - name: kubeconfig
    mountPath: "/root/.kube"
    readOnly: true
volumes:
  - name: kubeconfig
    secret:
      secretName: kubeconfig
runners:
  config: |
    concurrent = 3
    check_interval = 5

    [[runners]]
      name = "k8s-runner"
      url = "https://gitlab.com/"
      token = "$token"
      executor = "kubernetes"
      [runners.kubernetes]
        namespace = "gitlab-runner"
        privileged = true
        [runners.kubernetes.volumes]
          [[runners.kubernetes.volumes.secret]]
            name = "kubeconfig"
            mount_path = "/root/.kube"
            secret_name = "kubeconfig"
```


## values.yaml  serviceaccount version
```
gitlabUrl: https://gitlab.com/
runnerRegistrationToken: "$token"
replicas: 3
concurrency: 3
rbac:
  create: true
  generatedServiceAccountName: "gitlab-runner"
  rules:
    - resources: ["secrets", "pods", "pods/exec", "pods/attach"]
      verbs: ["get", "delete", "create", "update"]
serviceAccount:
  create: true    //外面那一層gitlab-runner 的 serviceAccount
runners:
  config: |
    concurrent = 3
    check_interval = 5
    [[runners]]
      name = "k8s-runner"
      url = "https://gitlab.com/"
      token = "$token"
      executor = "kubernetes"
      [runners.kubernetes]
        namespace = "dev"
        privileged = true
		service_account = "tgs-build"   //指定image 所使用的service account
```

## 安裝
```
export token="glrt-rDijy5CKWtzLsxueyDLJ"
envsubst < values.yaml | helm install -n gitlab-runner -f - backend gitlab/gitlab-runner
envsubst < values_helm.yaml | helm template -n gitlab-runner -f - backend-api-deploy gitlab/gitlab-runner
envsubst < values_helm.yaml | helm install -n gitlab-runner -f - backend-api-deploy gitlab/gitlab-runner
```

## rbac.yaml 
```
export namespace=staging
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-runner
  namespace: $namespace
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - services
  - ingresses
  - serviceaccounts
  - secrets
  - pods
  - pods/exec
  - pods/attach
  verbs:
  - create
  - update
  - delete
  - get
  - patch
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - create
  - get
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tgs-build-gitlab-runner
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: gitlab-runner
EOF
```