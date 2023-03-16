#!/bin/bash
for p in $(kubectl get deploy -n prod | grep -E 'lobby|ing-agent' | awk '{print $1}'); do 
	File="${p}.yaml"
	kubectl -n prod get deploy $p -o yaml > ${File};
done

for p in $(kubectl get ing -n prod | grep -E 'lobby|ing-agent' | awk '{print $1}'); do 
	File="${p}.yaml"
	kubectl -n prod get svc $p -o yaml > ${File};
done

for p in $(kubectl get ing -n prod | grep -E 'lobby|ing-agent' | awk '{print $1}'); do 
	File="${p}.yaml"
	kubectl -n prod get ing $p -o yaml > ${File};
done



for p in $(kubectl get deploy -n prod | grep gmo | awk '{print $1}'); do kubectl -n prod get deploy $p -o yaml > gmo/deploy.${p}.yaml; done

for p in $(kubectl get svc -n prod | grep gmo | awk '{print $1}'); do kubectl -n prod get svc $p -o yaml > gmo/svc.${p}.yaml; done

for p in $(kubectl get ing -n prod | grep gmo | awk '{print $1}'); do kubectl -n prod get ing $p -o yaml > gmo/ing.${p}.yaml; done


for p in $(kubectl get deploy -n prod | grep hkjp | awk '{print $1}'); do kubectl -n prod get deploy $p -o yaml > hkjp/deploy.${p}.yaml; done

for p in $(kubectl get svc -n prod | grep hkjp | awk '{print $1}'); do kubectl -n prod get svc $p -o yaml > hkjp/svc.${p}.yaml; done

for p in $(kubectl get ing -n prod | grep hkjp | awk '{print $1}'); do kubectl -n prod get ing $p -o yaml > hkjp/ing.${p}.yaml; done


for p in $(kubectl get deploy -n prod | grep mgm | awk '{print $1}'); do kubectl -n prod get deploy $p -o yaml > mgm/deploy.${p}.yaml; done

for p in $(kubectl get svc -n prod | grep mgm | awk '{print $1}'); do kubectl -n prod get svc $p -o yaml > mgm/svc.${p}.yaml; done

for p in $(kubectl get ing -n prod | grep mgm | awk '{print $1}'); do kubectl -n prod get ing $p -o yaml > mgm/ing.${p}.yaml; done




for p in $(kubectl get secrets -n prod | grep -E 'gmo|hkjp|mgm' | awk '{print $1}'); do kubectl -n prod delete secrets $p; done