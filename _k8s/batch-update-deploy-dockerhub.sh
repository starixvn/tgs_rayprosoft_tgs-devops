#!/bin/bash
tgsenv=staging
for p in $(kubectl get deploy -n $tgsenv | grep -E 'lobby|agent' | awk '{print $1}'); do 
	thisFile="${p}.yaml"
	kubectl -n $tgsenv get deploy $p -o yaml > ${thisFile};
	HasMaintenance=$(grep -n  "dockerhub" ${thisFile})
	echo "HasMaintenance=${HasMaintenance}"

	if [[ -z $HasMaintenance ]]
	then
		grep -n  "name: registry-credentials" ${thisFile} | tac | while read -r KeyLines;do  ## using tac to change sort order
			echo "line=$KeyLines"
			res=$(echo "${KeyLines/:      - name: registry-credentials/}")
			insertLine=$(expr $res + 1)
			echo "insertLine=${insertLine}"

			sed -i ${insertLine}'i \
      - name: dockerhub' ${thisFile}
	        break;
		done
		
		echo "output=${thisFile}"
		#kubectl apply -f ${IngressFile}
	fi
done
