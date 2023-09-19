# REF: https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

aws eks update-cluster-version --region ap-east-1 --name tgs-taiwan-staging --kubernetes-version 1.27


# REF: https://github.com/kubernetes/autoscaler/releases

kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.27.n

