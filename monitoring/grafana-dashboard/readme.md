# grafana setting
###### tags: `grafana`
https://hackmd.io/TLs4iiSuSOKb-wmQCNrttA

### Installation


https://github.com/grafana/helm-charts

    helm repo add grafana https://grafana.github.io/helm-charts

    helm upgrade --install grafana grafana/grafana -f values.yaml -n monitoring

    helm upgrade --install grafana grafana/grafana --set image.tag=8.1.3 -f values.yaml -n monitoring

    helm template grafana grafana/grafana -f values.yaml -n monitoring

	kubectl exec -it {{grafana-pods}} sh  -n monitoring
	
	run -> grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password EvTZYjTJ0eIDrWsIuo9GqGiNdQflRtneQnStkICJ
	
	
#### get password
    kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

    helm uninstall grafana -n monitoring

### Data Sources
#### => prometheus

url: http://prometheus-server

#### => cloudwatch 


### Notification Channel

##### staging 

https://gitlab.com/rayprosoft/notify-api/-/blob/master/NotifyApi/appsettings.json

token: 1652136804:AAFWBATSiBh-6wNIpoUXHCRNwSOa5J3fVfw

channel id: -1001368681345

![](https://i.imgur.com/fQZqHKb.png)


### image render return 401
https://github.com/grafana/grafana-image-renderer/issues/91
Don't use latest version, 3.5.0 can work.


increase((max without (instance) (etcd_server_leader_changes_seen_total{job=~".*etcd.*"}) or 0 * absent(etcd_server_leader_changes_seen_total{job=~".*etcd.*"}))[15m:1m]) >= 4
