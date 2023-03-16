#!/bin/bash
mkdir secrets
for p in $(kubectl -n staging get secrets  | grep Opaque | grep -v stg | awk '{print $1}'); do 
	kubectl get secrets $p -n staging -o yaml > secrets/$p.yaml ;
done

mkdir configmaps
for p in $(kubectl -n staging get configmap | awk '{print $1}'); do 
	kubectl get cm $p -n staging -o yaml > configmaps/$p.yaml ;
done

mkdir deployments
for p in $(kubectl -n staging get deployment | awk '{print $1}'); do 
	kubectl get deployment $p -n staging -o yaml > deployments/$p.yaml ;
done

mkdir services
for p in $(kubectl -n staging get services | awk '{print $1}'); do 
	kubectl get services $p -n staging -o yaml > services/$p.yaml ;
done

mkdir ingresses
for p in $(kubectl -n staging get ing | awk '{print $1}'); do 
	kubectl get ing $p -n staging -o yaml > ingresses/$p.yaml ;
done
