# install ECK 
# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html

kubectl apply -f https://download.elastic.co/downloads/eck/2.7.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.7.0/operator.yaml