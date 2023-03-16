#!/bin/bash
tgsenv=staging
for p in $(kubectl get sa -n $tgsenv | awk '{print $1}'); do 
	thisFile="${p}.yaml"
	kubectl -n $tgsenv get sa $p -o yaml > ${thisFile};
	sed -i 's/nonprod/staging/g' ${thisFile}
	
	for i in {1..4}
	do
	   sed -i '4d' ${thisFile}
	done
done
