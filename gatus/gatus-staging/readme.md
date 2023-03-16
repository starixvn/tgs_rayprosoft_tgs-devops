### 新增 helm repo 
helm repo add gatus https://avakarev.github.io/gatus-chart
helm repo update

### 服務檔案
services: https://docs.google.com/spreadsheets/d/1aKM0LlNc96vuZZeqQdKlBLveBm0I0h-zsklvqhurjzM/edit#gid=0
download to staging-services.csv
執行 bash convert_to_configmap.sh 來產生 configmap 檔案 cm_gatus.yaml


### 執行安裝
helm template gatus gatus/gatus --set-file config=config.yaml --set ingress.enabled=true --set ingress.hosts[0]=stg-gatus.rpgp.cc -f values.yaml -n staging

helm install gatus gatus/gatus --set-file config=config.yaml --set ingress.enabled=true --set ingress.hosts[0]=stg-gatus.rpgp.cc -f values.yaml -n staging


### 更新 configmap
kubectl apply -f cm_gatus.yaml
kubectl rollout restart deploy gatus -n staging
REF: https://github.com/TwiN/gatus#monitoring-a-tcp-endpoint