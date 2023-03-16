#!/bin/bash
tgsenv=staging
for p in $(kubectl get deploy -n $tgsenv | awk '{print $1}'); do 
	thisFile="${p}.yaml"
	kubectl -n $tgsenv get deploy $p -o yaml > ${thisFile};
	sed -i 's/nonprod/staging/g' ${thisFile}
	
	for i in {1..6}
	do
	   sed -i '4d' ${thisFile}
	done
	
	grep -n  "resourceVersion" ${thisFile} | while read -r KeyLines;do  ## using tac to change sort order
		echo "line=$KeyLines"
		res=$(echo "${KeyLines/:      resourceVersion/}")
        res=${res:0:2}
		res=$(echo "$res" |  sed 's/://g')
		echo "res=$res"
		
		sed -i '"$res"'d ${thisFile}
		break;
	done
	
	#kubectl apply -f ${thisFile}
done
