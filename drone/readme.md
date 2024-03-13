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

902660445e179448d33486d789d0c200d3d58da39a98a97bd4ce7bd657d4a740
gloas-79da82a4457f16482b19a7a76663b071693b26f916794519dec7638481c3d063


## github

User > Settings > Developer Settings > OAuth Apps

https://github.com/settings/developers




## runner
https://github.com/drone/charts/tree/master/charts/drone-runner-docker

helm upgrade -i drone-runner drone/drone-runner-docker --namespace drone --values drone-runner-values.yaml

https://docs.drone.io/runner/kubernetes/installation/