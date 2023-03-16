https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/create-kubeconfig.html

aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-k8s
aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-staging2

kubectl patch deploy -n kube-system coredns            --type='json' -p='[{"op": "add", "path": "/spec/template/spec/tolerations/-", "value": {"operator": "Exists", "key": "dedicated","effect": "NoSchedule"}}]'
kubectl patch deploy -n kube-system ebs-csi-controller --type='json' -p='[{"op": "add", "path": "/spec/template/spec/tolerations/-", "value": {"operator": "Exists", "key": "dedicated","effect": "NoSchedule"}}]'


helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler  eks/aws-node-termination-handler --namespace kube-system --version 0.15.4             


### load-balancer-controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
	--set clusterName=tgs-taiwan-staging2 \
	--set serviceAccount.create=true \
	--set serviceAccount.name=aws-load-balancer-controller


helm template aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
	--set clusterName=tgs-taiwan-staging2 \
	--set serviceAccount.create=true \
	--set serviceAccount.name=aws-load-balancer-controller
	

helm uninstall aws-load-balancer-controller -n kube-system 


### metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml






### ingress
https://docs.aws.amazon.com/zh_tw/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus-Sample-Workloads-nginx.html

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create namespace ingress-nginx

helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"


export lbname=$(kubectl get svc -n ingress-nginx --output jsonpath='{.items[?(@.spec.type contains 'LoadBalancer')].status.loadBalancer.ingress[0].hostname}')



bash tgs-devops/terraform/install-infra/create_dns_record-staging.sh $lbname
bash tgs-devops/terraform/install-infra/delete_dns_record-staging.sh $lbname

bash tgs-devops/terraform/install-infra/delete_dns_record-staging.sh $lbname



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


kubectl apply -f tgs-devops/terraform/deployment-files/secrets/
kubectl apply -f tgs-devops/terraform/deployment-files/configmaps/
kubectl apply -f tgs-devops/terraform/deployment-files/deployments/
kubectl apply -f tgs-devops/terraform/deployment-files/services/
kubectl apply -f tgs-devops/terraform/deployment-files/ingresses/

kubectl apply -f tgs-devops/terraform/deployment-files/secrets/
kubectl apply -f tgs-devops/terraform/deployment-files/configmaps/
kubectl apply -f tgs-devops/terraform/deployment-files/deployments/
kubectl apply -f tgs-devops/terraform/deployment-files/services/
kubectl apply -f tgs-devops/terraform/deployment-files/ingresses/


helm uninstall ingress-nginx -n ingress-nginx



# https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html

aws eks tag-resource --resource-arn arn:aws:eks:ap-east-1:060812454361:cluster/tgs-taiwan-staging2 --tags kubernetes.io/role/internal-elb=1

aws eks untag-resource --resource-arn arn:aws:eks:ap-east-1:060812454361:cluster/tgs-taiwan-staging2 --tag-keys tag_key

aws eks list-tags-for-resource --resource-arn arn:aws:eks:ap-east-1:060812454361:cluster/tgs-taiwan-staging2

### 要在 public subnet 加 tag kubernetes.io/cluster/tgs-taiwan-staging2=shared
aws eks tag-resource --resource-arn arn:aws:ec2:ap-east-1:060812454361:subnet/subnet-0d1cf87af016cf91a --tags kubernetes.io/cluster/tgs-taiwan-staging2=shared


### ingress 2 
https://kubernetes.github.io/ingress-nginx/deploy/#aws
https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html


wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml

	10.139.0.0/16


#### note: Do not edit the annotations after creating your service. If you need to modify it, delete the service object and create it again with the desired value for this annotation.

sed -i 's/XXX.XXX.XXX\/XX/10.139.0.0\/16/g' deploy.yaml

### auto-scaler
https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/autoscaling.html


aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json

aws iam delete-policy \
    --policy-arn arn:aws:iam::060812454361:policy/AmazonEKSClusterAutoscalerPolicy 


eksctl create iamserviceaccount \
  --cluster=tgs-taiwan-staging2 \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::060812454361:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

eksctl delete iamserviceaccount \
  --cluster=tgs-taiwan-staging2 \
  --namespace=kube-system \
  --name=cluster-autoscaler


curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

sed -i 's/<YOUR CLUSTER NAME>/tgs-taiwan-staging2/g' cluster-autoscaler-autodiscover.yaml
sed -i '163 a\ \ \ \ \ \ \ \ \ \ \ \ - --balance-similar-node-groups' cluster-autoscaler-autodiscover.yaml
sed -i '164 a\ \ \ \ \ \ \ \ \ \ \ \ - --skip-nodes-with-system-pods=false' cluster-autoscaler-autodiscover.yaml

kubectl apply -f cluster-autoscaler-autodiscover.yaml

# kubectl annotate serviceaccount cluster-autoscaler \
#  -n kube-system \
#  eks.amazonaws.com/role-arn=arn:aws:iam::060812454361:role/AmazonEKSClusterAutoscalerRole

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'


### csi installer

https://www.eksworkshop.com/beginner/170_statefulset/ebs_csi_driver/


https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#adding-ebs-csi-eks-add-on

https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#updating-ebs-csi-eks-add-on


arn:aws:iam::118936045135:role/ebs-csi-iam-role

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon --name aws-ebs-csi-driver --cluster tgs-taiwan-k8s --service-account-role-arn arn:aws:iam::118936045135:role/AmazonEKS_EBS_CSI_DriverRole --force

eksctl update addon --name aws-ebs-csi-driver --version v1.11.4-eksbuild.1 --cluster my-cluster --force

eksctl delete addon --cluster my-cluster --name aws-ebs-csi-driver --preserve



aws sts get-caller-identity
eksctl get iamidentitymapping --cluster tgs-taiwan-k8s



eksctl create iamidentitymapping --cluster tgs-taiwan-k8s --arn arn:aws:iam::060812454361:policy/eks-stagging --username eks_tgs-taiwan-k8s-staging --region=ap-east-1
eksctl create iamidentitymapping --cluster tgs-taiwan-k8s --arn arn:aws:iam::060812454361:user/stagingk8suser --username eks_tgs-taiwan-k8s-staging --region=ap-east-1



### git clone
git clone https://lester.wei:1q2w3e4r@gitlab.com/rayprosoft/tgs-devops.git

bash tgs-devops/terraform/install-infra/create_dns_record-staging.sh a33294a5cf54543129086da3543f721d-1416873855.ap-east-1.elb.amazonaws.com


### install nats, redis, mongodb
kubectl create ns staging 
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install nats nats/nats --set metrics.enabled=true,auth.enabled=false,cluster.enabled=true,cluster.name=nats,cluster.replicas=3 -n staging
helm install mongodb bitnami/mongodb --set auth.rootPassword=1qaz2wsx,auth.enabled=false,metrics.enabled=true,image.tag=5.0.9-debian-11-r3 -n staging

### rabbitmq
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)


export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

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

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rabbitmq
  namespace: rabbitmq
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules: 
  - host: stg2-rabbitmq.rpgp.cc
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: mq
            port: 
              number: 15672
EOF