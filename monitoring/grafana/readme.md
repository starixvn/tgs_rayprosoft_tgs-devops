https://hub.docker.com/r/grafana/grafana/tags
https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md

helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -f values.yaml -n monitoring


helm upgrade --install grafana grafana/grafana -f values2-dev.yaml -n monitoring

helm upgrade --install grafana2 grafana/grafana -f values2-staging.yaml -n monitoring

helm upgrade --install grafana2 grafana/grafana -f values2-prod.yaml -n monitoring

helm upgrade --install grafana grafana/grafana -f values-prod.yaml -n monitoring



### grafana backup/restore

sudo apt install -y python-pip
git clone https://github.com/ysde/grafana-backup-tool.git
cd grafana-backup-tool
sudo pip install .

cp examples/grafana-backup.example.json grafana-backup.json
cp examples/grafana-backup.example.json grafana-restore.json

sudo grafana-backup save --config=backup-dev.json
sudo grafana-backup save --config=backup-staging.json
sudo grafana-backup save --config=backup-prod.json

sudo grafana-backup restore --config=restore-dev.json   _OUTPUT_/202211250207.tar.gz
sudo grafana-backup restore --config=restore-staging.json   _OUTPUT_/202211250207.tar.gz
sudo grafana-backup restore --config=restore-prod.json   _OUTPUT_/202211250207.tar.gz

### k8s grafana backup

kubectl apply -f backup-cronjob-dev.yaml
kubectl apply -f backup-cronjob-staging.yaml
kubectl apply -f backup-cronjob-prod.yaml

#### dev

grafana 
password: EvTZYjTJ0eIDrWsIuo9GqGiNdQflRtneQnStkICJ
backup 
token: eyJrIjoiUEVzWTgxT2tobGxBMUt3TE4wQUdpQ2NZaE5maTlEWHYiLCJuIjoiYmFja3VwIiwiaWQiOjF9
curl -H "Authorization: Bearer eyJrIjoiUEVzWTgxT2tobGxBMUt3TE4wQUdpQ2NZaE5maTlEWHYiLCJuIjoiYmFja3VwIiwiaWQiOjF9" https://grafana.rpgp.cc/api/dashboards/home


grafana2 
password: E4aY66CizH8aYT8TDQkiJkVZCamRXtndS1OB2GLw
backup
token: eyJrIjoiMms0UjNaTW40WjZhMHJpZDJhT2dKSFlBSkhtbVhWT2kiLCJuIjoicmVzdG9yZSIsImlkIjoxfQ==
curl -H "Authorization: Bearer eyJrIjoiMms0UjNaTW40WjZhMHJpZDJhT2dKSFlBSkhtbVhWT2kiLCJuIjoicmVzdG9yZSIsImlkIjoxfQ==" https://grafana2.rpgp.cc/api/dashboards/home

sudo grafana-backup restore --config=grafana-restore.json   _OUTPUT_/202211250207.tar.gz


#### staging

grafana 
password: EvTZYjTJ0eIDrWsIuo9GqGiNdQflRtneQnStkICJ
backup 
token: eyJrIjoiSXkzMUFWdDBveGllMWdEUDRzMmdxM0ZBVmJHSG0xcXIiLCJuIjoiYmFja3VwIiwiaWQiOjF9
curl -H "Authorization: Bearer eyJrIjoiSXkzMUFWdDBveGllMWdEUDRzMmdxM0ZBVmJHSG0xcXIiLCJuIjoiYmFja3VwIiwiaWQiOjF9" https://stg-grafana.rpgp.cc/api/dashboards/home


grafana2 
password: aEUDrkB2uKLfnClResYwZbGX8qOODSQAbQTVDQfP
backup
token: eyJrIjoiMms0UjNaTW40WjZhMHJpZDJhT2dKSFlBSkhtbVhWT2kiLCJuIjoicmVzdG9yZSIsImlkIjoxfQ==
curl -H "Authorization: Bearer eyJrIjoiMms0UjNaTW40WjZhMHJpZDJhT2dKSFlBSkhtbVhWT2kiLCJuIjoicmVzdG9yZSIsImlkIjoxfQ==" https://grafana2.rpgp.cc/api/dashboards/home

sudo grafana-backup save --config=staging-grafana-backup.json
sudo grafana-backup restore --config=_staging-grafana-restore.json  202211280727.tar.gz

#### prod

grafana 
password: EvTZYjTJ0eIDrWsIuo9GqGiNdQflRtneQnStkICJ
backup 
token: eyJrIjoiSzN4eHdrWWp1eDBlcXgyb0NueXhwTzRTZ2o2aHF4MHciLCJuIjoiYmFja3VwIiwiaWQiOjF9
curl -H "Authorization: Bearer eyJrIjoiSzN4eHdrWWp1eDBlcXgyb0NueXhwTzRTZ2o2aHF4MHciLCJuIjoiYmFja3VwIiwiaWQiOjF9" https://grafana.yydsgo.xyz/api/dashboards/home


grafana2 
password: p184ycP4RU4VXpC8E0NxkXa5MntSsbnzkzg6PxI2
backup
token: eyJrIjoiZjZ3SWpLSUpFSVFCYzMybUJ1V2Y3b2dUU1E4WFNVQkkiLCJuIjoicmVzdG90ciIsImlkIjoxfQ==
curl -H "Authorization: Bearer eyJrIjoiZjZ3SWpLSUpFSVFCYzMybUJ1V2Y3b2dUU1E4WFNVQkkiLCJuIjoicmVzdG90ciIsImlkIjoxfQ==" https://grafana2.yydsgo.xyz/api/dashboards/home

sudo grafana-backup save --config=_prod-grafana-backup.json
sudo grafana-backup restore --config=restore-prod.json  202211290639.tar.gz


### Notification Settings

go to Alert > Contact points > New contact point


tgs_user_bot TOKEN: 1652136804:AAFWBATSiBh-6wNIpoUXHCRNwSOa5J3fVfw
TGS TOKEN: 1780137038:AAHDIVxs2somlHZ5QbZKq1X403NnWAPXVn4
 
[TGS-Database] -1001303731430
[Jenkins ] -1001114115188

[dev tgs error notify] -1001211440897
[Staging tgs error notify] -1001331338194
[Production tgs error notify] -1001421081363

[Prod_Monitor] -1001626239965 
[Staging_Monitor] -1001368681345
