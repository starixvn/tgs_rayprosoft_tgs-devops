## install drone 
##### REF : https://github.com/drone/charts/blob/master/charts/drone/docs/install.md

```
kubectl create ns drone
helm repo add drone https://charts.drone.io
helm repo update

helm template --namespace drone drone-github drone/drone -f drone-github-values.yaml | kubectl -n drone apply -f -
helm template --namespace drone drone-gitlab drone/drone -f drone-gitlab-values.yaml | kubectl -n drone apply -f -

helm upgrade -i --namespace drone drone drone/drone -f drone-values.yaml
```

## gitlab

User > Edit Profile > Applications

https://gitlab.com/-/profile/applications

06ac24d09b0ddb575c58815154fb2720864c61282fcfa0cd831d7978e813b6e7
gloas-737e1aa39790bf17427be3ff20f44f0e14487ae1c85bd1ec920f7be1da9504b8


## github

User > Settings > Developer Settings > OAuth Apps

https://github.com/settings/developers




## runner
https://github.com/drone/charts/tree/master/charts/drone-runner-docker

helm upgrade -i drone-runner drone/drone-runner-docker --namespace drone --values drone-runner-values.yaml

https://docs.drone.io/runner/kubernetes/installation/


## go module proxy server
https://www.youtube.com/watch?v=964fZJPVHDI
https://docs.gomods.io/install/install-on-kubernetes/
https://github.com/gomods/athens-charts/blob/main/charts/athens-proxy/values.yaml

```
helm repo add gomods https://gomods.github.io/athens-charts
helm repo update
helm upgrade -i gomods/athens-proxy -n drone -f athens-proxy-values.yaml

```
