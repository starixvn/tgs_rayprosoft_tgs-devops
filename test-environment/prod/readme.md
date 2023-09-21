## 取得 kubeconfig
aws eks update-kubeconfig --name tgs-taiwan-k8s2

## install-base.sh
aws-cli, eksctl, helm, krew, bash-completion 安裝

## 基本安裝
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
kubectl apply -f ./cluster-issuer.yml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


## 安裝 velero
export BUCKET=tgs-prod-backup
export REGION=ap-east-1

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.4.0 \
  --bucket $BUCKET \
  --backup-location-config region=$REGION \
  --snapshot-location-config region=$REGION \
  --secret-file ~/.credentials-velero

## 備份
velero backup create ingress-nginx --include-namespaces ingress-nginx
velero backup get

## 還原
velero restore create nginx-ingress-controller --from-backup nginx-ingerss-controller
velero restore create ingress-nginx --from-backup ingress-nginx

velero restore create ingress --from-backup ingress
velero restore create certificate --from-backup certificate


