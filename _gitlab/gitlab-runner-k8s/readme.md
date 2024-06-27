# gitlab-runner install k8s
https://gitlab.cn/blog/2021/12/09/runner-k8s/

https://chatgpt.com/share/bd4520e8-47e8-4d2e-a35f-a98fbfb91b73

https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/values.yaml


## 前置作業
```
kubectl create ns gitlab-runner
kubectl create secret generic kubeconfig --from-file=/home/ubuntu/.kube/config -n gitlab-runner
```
## values.yaml
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
## 安裝
```
export token="glrt-rDijy5CKWtzLsxueyDLJ"
envsubst < values.yaml | helm install -n gitlab-runner -f - backend gitlab/gitlab-runner
```

## rbac.yaml 
```
export namespace=staging
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $namespace
  name: gitlab-runner-role
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-rolebinding
  namespace: $namespace
subjects:
- kind: ServiceAccount
  name: default
  namespace: gitlab-runner
roleRef:
  kind: Role
  name: gitlab-runner-role
  apiGroup: rbac.authorization.k8s.io
EOF
```