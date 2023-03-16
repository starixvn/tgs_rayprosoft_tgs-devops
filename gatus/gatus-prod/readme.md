### 新增 helm repo 
helm repo add gatus https://avakarev.github.io/gatus-chart
helm repo update

### 服務檔案
kubectl get svc -n prod | awk '{print $1}' > service.txt
services: https://docs.google.com/spreadsheets/d/1aKM0LlNc96vuZZeqQdKlBLveBm0I0h-zsklvqhurjzM/edit#gid=1903529837
download to staging-services.csv
執行 bash convert_to_configmap.sh 來產生 configmap 檔案 cm_gatus.yaml


### 執行安裝
helm template gatus gatus/gatus --set-file config=config.yaml --set ingress.enabled=true --set ingress.hosts[0]=healthcheck.srvptt.com -f values.yaml -n prod

helm install gatus gatus/gatus --set-file config=config.yaml --set ingress.enabled=true --set ingress.hosts[0]=healthcheck.srvptt.com -f values.yaml -n prod

helm uninstall gatus -n prod


### 更新 configmap
bash convert_to_configmap.sh & kubectl apply -f cm_gatus.yaml & kubectl rollout restart deploy gatus -n prod 
check on https://healthcheck.srvptt.com

REF: https://github.com/TwiN/gatus#monitoring-a-tcp-endpoint