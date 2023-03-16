#!/bin/bash

aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-staging2
git clone https://lester.wei:1q2w3e4r@gitlab.com/rayprosoft/tgs-devops.git

### aws-node-termination-handler
echo "install aws-node-termination-handler"

helm install aws-node-termination-handler  eks/aws-node-termination-handler --namespace kube-system

helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler  eks/aws-node-termination-handler --namespace kube-system --version 0.15.4             

### auto-scaler
# https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/autoscaling.html
echo "install auto-scaler"

aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json

eksctl create iamserviceaccount \
  --cluster=tgs-taiwan-staging2 \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::060812454361:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

sed -i 's/<YOUR CLUSTER NAME>/tgs-taiwan-staging2/g' cluster-autoscaler-autodiscover.yaml
sed -i '163 a\ \ \ \ \ \ \ \ \ \ \ \ - --balance-similar-node-groups' cluster-autoscaler-autodiscover.yaml
sed -i '164 a\ \ \ \ \ \ \ \ \ \ \ \ - --skip-nodes-with-system-pods=false' cluster-autoscaler-autodiscover.yaml

kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'


### metrics
echo "install metrics"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


### ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create namespace ingress-nginx

helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"

### rabbitmq
echo "install rabbitmq"
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
kubectl create ns rabbitmq

cat <<EOF | kubectl apply -f -
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: mq
  namespace: rabbitmq
spec:
  replicas: 1
  rabbitmq:
    additionalConfig: |
      default_user=tgs
      default_pass=TgsP@ssw0rd
      default_vhost=/tgs/staging
      default_user_tags.administrator=true
      default_permissions.configure=.*
      default_permissions.read=.*
      default_permissions.write=.*
EOF

### install nats, redis, mongodb
echo "install nats, redis, mongodb"
kubectl create ns staging
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n staging

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install mongodb bitnami/mongodb --set auth.rootPassword=1qaz2wsx,auth.enabled=false,metrics.enabled=true,image.tag=5.0.9-debian-11-r3 -n staging
helm install redis bitnami/redis --set password=1qaz2wsx,auth.enabled=false,metrics.enabled=true -n staging


### cert-manager
echo "install cert-manager"
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.crds.yaml

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.10.1 \
  --set prometheus.enabled=false \
  --set webhook.timeoutSeconds=4 

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: lester.stock@gmail.com
    privateKeySecretRef:
      name: letsencrypt-secret
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

export lbname=$(kubectl get svc -n ingress-nginx --output jsonpath='{.items[?(@.spec.type contains 'LoadBalancer')].status.loadBalancer.ingress[0].hostname}')

bash tgs-devops/terraform/install-infra/delete_dns_record-staging.sh
bash tgs-devops/terraform/install-infra/create_dns_record-staging.sh $lbname

kubectl apply -f tgs-devops/terraform/deployment-files/secrets/
kubectl apply -f tgs-devops/terraform/deployment-files/configmaps/
kubectl apply -f tgs-devops/terraform/deployment-files/deployments/
kubectl apply -f tgs-devops/terraform/deployment-files/services/

FILES="/home/ec2-user/tgs-devops/terraform/deployment-files/ingresses/*"
for f in $FILES
do
  sed -i 's/stg-/stg2-/g' $f
  sed -i -n -e :a -e '1,4!{P;N;D;};N;ba' $f
  kubectl apply -f $f -n staging
  cat $f
  echo "======================="
done

