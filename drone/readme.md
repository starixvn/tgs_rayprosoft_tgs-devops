## install drone 
##### REF : https://github.com/drone/charts/blob/master/charts/drone/docs/install.md

```
kubectl create ns drone
helm repo add drone https://charts.drone.io
helm repo update

helm template --namespace drone drone drone/drone -f drone-values.yaml
helm upgrade -i --namespace drone drone drone/drone -f drone-values.yaml
```