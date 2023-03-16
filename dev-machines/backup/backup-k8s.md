### roles
mkdir ./sa
for p in $(kubectl get roles -n dev | grep -v -E 'nats|redis|redisinsight-redisinsight-chart|default' | awk '{print $1}'); do echo $p; \
	kubectl get roles  $p -n dev -o yaml > roles/$p.yaml;echo "=============";done
rm secrets/NAME.yaml

### service account
mkdir ./sa
for p in $(kubectl get sa -n dev | grep -v -E 'nats|redis|redisinsight-redisinsight-chart|default' | awk '{print $1}'); do echo $p; \
	kubectl get sa  $p -n dev -o yaml > sa/$p.yaml;echo "=============";done
rm secrets/NAME.yaml

### secrets
mkdir ./secrets
for p in $(kubectl get secrets -n dev | grep -v -E 'token|helm' | awk '{print $1}'); do echo $p; \
	kubectl get secrets  $p -n dev -o yaml > secrets/$p.yaml;echo "=============";done
rm secrets/NAME.yaml

### configmaps
mkdir ./configmaps
for p in $(kubectl get cm -n dev | awk '{print $1}'); do echo $p; \
	kubectl get cm  $p -n dev -o yaml > configmaps/$p.yaml;echo "=============";done
rm configmaps/NAME.yaml

### deployment
mkdir ./deployments
for p in $(kubectl get deploy -n dev | awk '{print $1}'); do echo $p; \
	kubectl get deploy  $p -n dev -o yaml > deployments/$p.yaml;echo "=============";done
rm deployments/NAME.yaml

### services
mkdir ./services
for p in $(kubectl get svc -n dev | awk '{print $1}'); do echo $p; \
	kubectl get svc  $p -n dev -o yaml > services/$p.yaml;echo "=============";done
rm services/NAME.yaml

### ingress
mkdir ./ingress
for p in $(kubectl get ing -n dev | awk '{print $1}'); do echo $p; \
	kubectl get ing  $p -n dev -o yaml > ingress/$p.yaml;echo "=============";done
rm ingress/NAME.yaml

### ingress
mkdir ./cronjobs
for p in $(kubectl get cronjobs -n dev | awk '{print $1}'); do echo $p; \
	kubectl get cronjobs  $p -n dev -o yaml > cronjobs/$p.yaml;echo "=============";done
rm cronjobs/NAME.yaml
	