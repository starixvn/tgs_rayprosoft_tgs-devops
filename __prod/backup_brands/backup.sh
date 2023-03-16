#!/bin/bash
export brand=28bet
sudo mkdir -p $brand;
for p in $(kubectl get deploy -n prod | grep $brand | awk '{print $1}'); do
        if [[ ${p} != "agent-api" ]]; then
                thisFile="${p}.yaml"
                kubectl -n prod get deploy $p -o yaml > ./$brand/deploy.${thisFile};
        fi
done;

for p in $(kubectl get svc -n prod | grep $brand | awk '{print $1}'); do
        if [[ ${p} != "agent-api" ]]; then
                thisFile="${p}.yaml"
                kubectl -n prod get svc $p -o yaml > ./$brand/svc.${thisFile};
        fi
done;

for p in $(kubectl get ing -n prod | grep -E $brand | awk '{print $1}'); do
        if [[ ${p} != "agent-api" ]]; then
                thisFile="${p}.yaml"
                kubectl -n prod get ing $p -o yaml > ./$brand/ing.${thisFile};
        fi
done;




for p in $(kubectl -n prod get secrets | grep $brand | awk '{print $1}'); do kubectl delete secrets $p -n prod --grace-period=0 --force;done
     