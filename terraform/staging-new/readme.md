terraform plan -var-file vars-dev.tf

terraform plan -var-file vars-prod.tf

terraform apply -var-file vars-prod.tf -auto-approve

terraform destroy -var-file vars-prod.tf -auto-approve


aws configure

AKIARXMJEAZHQXZMA45B 
cdcpD5N+pzyY/oHGzPAxu7zECifq240zYTTANVUg


https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/create-kubeconfig.html

aws eks update-kubeconfig --region ap-east-1 --name tgs-taiwan-k8s



curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh
./get_helm.sh


helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler  eks/aws-node-termination-handler --namespace kube-system --version 0.15.4             


### load-balancer-controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
	--set clusterName=tgs-taiwan-k8s \
	--set serviceAccount.create=false \
	--set serviceAccount.name=aws-load-balancer-controller


helm template aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
	--set clusterName=tgs-taiwan-k8s \
	--set serviceAccount.create=false \
	--set serviceAccount.name=aws-load-balancer-controller
	

helm uninstall aws-load-balancer-controller -n kube-system 


kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml



eksctl create iamidentitymapping --cluster tgs-taiwan-k8s --arn arn:aws:iam::060812454361:policy/eks-stagging --username eks_tgs-taiwan-k8s-staging --region=ap-east-1
eksctl create iamidentitymapping --cluster tgs-taiwan-k8s --arn arn:aws:iam::060812454361:user/stagingk8suser --username eks_tgs-taiwan-k8s-staging --region=ap-east-1



### ingress
https://docs.aws.amazon.com/zh_tw/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus-Sample-Workloads-nginx.html

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create namespace nginx-ingress-sample

helm install nginx-ingress ingress-nginx/ingress-nginx \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"

### auto-scaler
https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/autoscaling.html



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



# Docker Login
runuser -l ec2-user -c 'docker login --username pgtgs --password dckr_pat_vkNUTpZr_o0zsiGGgfXnrgivBZo'



amazon-eks-node-1.25-v20230322
ami-0b11f7a95c41965c8
