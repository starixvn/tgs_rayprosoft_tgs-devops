https://hub.docker.com/r/grafana/grafana/tags
https://github.com/grafana/helm-charts/tree/main/charts/grafana

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade -i grafana grafana/grafana -f grafana-config.yaml -n monitoring
helm uninstall grafana -n monitoring

kubectl get secret --namespace monitoring grafana2 -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


### grafana backup/restore

sudo apt install -y pytho3-pip
git clone https://github.com/ysde/grafana-backup-tool.git
cd grafana-backup-tool
sudo pip install .

cp examples/grafana-backup.example.json grafana-backup.json
cp examples/grafana-backup.example.json grafana-restore.json

sudo grafana-backup save --config=/home/ubuntu/tgs-deployment/monitoring/staging/grafana-backup-restore/backup.json
sudo grafana-backup restore --config=/home/ubuntu/tgs-deployment/monitoring/staging/grafana-backup-restore/restore.json  202308300705.tar.gz

### k8s grafana backup

kubectl apply -f backup-cronjob-staging.yaml

#### staging

grafana 
password: EvTZYjTJ0eIDrWsIuo9GqGiNdQflRtneQnStkICJ
backup 
產生token
Home > Administration > Service accounts >> Add service account >>  Add service account token

export token=glsa_ZTaL9SLaJowuY8tRZbp1ryzGJOC4Y3I2_aa54307b
curl -H "Authorization: Bearer $token" https://stg-grafana.rpgp.cc/api/dashboards/home

### Notification Settings

go to Alert > Contact points > New contact point

tgs_user_bot TOKEN: 
6137223098:AAEeQiBaQ1G1Gj5pO7p9q_FVwvXViM1BMcg
chat_id=-1001928893410
