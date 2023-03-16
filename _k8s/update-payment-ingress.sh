#!/bin/bash
for p in $(kubectl get ing -n prod | grep -E 'lobby|ing-agent' | awk '{print $1}'); do 
	IngressFile="${p}.yaml"
	kubectl -n prod get ing $p -o yaml > ${IngressFile};
	HasMaintenance=$(grep -n  "path: /api/brand/maintenance" ${IngressFile})
	echo "HasMaintenance=${HasMaintenance}"

	if [[ -z $HasMaintenance ]]
	then
		grep -n  "path: /api/brandlivechat" ${IngressFile} | tac | while read -r KeyLines;do  ## using tac to change sort order
			echo "line=$KeyLines"
			res=$(echo "${KeyLines/:        path: \/api\/brandlivechat/}")
			insertLine=$(expr $res + 2)
			echo "insertLine=${insertLine}"

			sed -i ${insertLine}'i \
      - backend:\
          service:\
            name: brand-api\
            port:\
              number: 80\
        path: /api/brand/maintenance\
        pathType: Prefix' ${IngressFile}
		done
		
		echo "output=${IngressFile}"
		#kubectl apply -f ${IngressFile}
	fi
done
