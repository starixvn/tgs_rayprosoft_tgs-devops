#!/bin/bash
for p in $(kubectl get deploy -n prod | grep -E 'lobby' | awk '{print $1}'); do 
	if [[ ${p} =~ "lobby-gp" ]]; then
		thisFile="${p}.yaml"
		kubectl -n $tgsenv get deploy $p -o yaml > ${thisFile};
		yq -i e '.spec.template.spec.nodeSelector.dedicated = "frontend" | .spec.template.spec.tolerations[0].value = "frontend"' ${thisFile}
	fi
done
