#!/bin/bash
for p in $(kubectl get deploy -n prod | grep -E 'lobby' | grep lobby-gpi  | awk '{print $1}'); do 
       thisFile="${p}.yaml"

       echo ${thisFile}

       kubectl -n prod get deploy $p -o yaml > ${thisFile};
	#yq -i e '.spec.template.spec.nodeSelector.dedicated = "frontend" | .spec.template.spec.tolerations[0].value = "frontend"' ${thisFile}
       insertLine2=$(grep -n  "containers:" ${thisFile} | cut -c 1-2)
       insertLine0=$(expr $insertLine2 - 10)
       insertLine1=$(expr $insertLine2 - 1)

       echo "${insertLine},${insertLine2}"
#       sed -i $insertLine0','$insertLine1'd' ${thisFile}

       podAffinityLine=$(grep -n  "affinity:" ${thisFile})
       echo "podAffinityLine=${podAffinityLine}"       

       if [[ -z "${podAffinityLine}" ]]; then 
           echo "加 podAffinityLine :  ${thisFile}:${insertLine2}:${insertLine}"
#           sed -i ${insertLine2}'i \
#      affinity:\
#        podAffinity:\
#          requiredDuringSchedulingIgnoredDuringExecution:\
#          - labelSelector:\
#              matchExpressions:\
#              - key: type\
#                operator: In\
#                values:\
#                - frontend\
#            topologyKey: kubernetes.io/hostname' ${thisFile}
       else
	   echo "delete podAffinity"
	   affinityLine=$(grep -n  "affinity:" ${thisFile} | cut -c 1-2)
           affinityLine2=$(expr $affinityLine + 9)
	   echo "affinityLine=${affinityLine}:${affinityLine2}"
	   sed -i ${affinityLine}','${affinityLine2}'d' ${thisFile}
       fi 

       deleteLine=$(grep -n  "nodeSelector:" ${thisFile} | cut -c 1-3)
       deleteLine2=$(expr $deleteLine + 1)
       echo "deleteNodeSelectorLine:${deleteLine}:${deleteLine2}"

       if [[ ! -z "$deleteLine" ]]; then
           echo "delete nodeSelector"
     # sed -i ${deleteLine}'d' ${thisFile} 
     # sed -i ${deleteLine}'d' ${thisFile}
       else 
	   echo "add nodeSelector"    
	   tolerationLine=$(grep -n  "tolerations:" ${thisFile} | cut -c 1-3)
	   echo "tolerationLine:${tolerationLine}"
           sed -i ${tolerationLine}'i \
      nodeSelector:\
        dedicated: frontend' ${thisFile}
       fi 

       ### 加topologySpreadConstraints

       hasNoTopologySpread=$(grep -n "      topologySpreadConstraints:" ${thisFile})
       echo "hasNoTopologySpread=$hasNoTopologySpread"

       if [[ -z ${hasNoTopologySpread}  ]]; then 
          echo "add topologySpreadConstraints"	  
#	  echo "add topologySpreadConstraints"

#          topologySpreadLine=$(grep -n  "volumes:" ${thisFile} | cut -c 1-3)
#	  echo "topologySpreadLine=${topologySpreadLine}"

##	  topologySpreadLine2=$(expr $topologySpreadLine - 1)

#           sed -i ${topologySpreadLine}'i \
#      topologySpreadConstraints:\
#      - labelSelector:\
#          matchLabels:\
#            dedicated: frontend\
#        maxSkew: 1\
#        topologyKey: kubernetes.io/hostname\
#        whenUnsatisfiable: DoNotSchedule' ${thisFile}
       else
   	   deleteTopologySpreadLine=$(echo $hasNoTopologySpread | cut -c 1-3)
	   echo "deleteTopologySpreadLine:${deleteTopologySpreadLine}"
           deleteTopologySpreadLine2=$(expr $deleteTopologySpreadLine + 6)	  
	   echo "deleteTopologySpreadLine:$deleteTopologySpreadLine:$deleteTopologySpreadLine2"
           sed -i ${deleteTopologySpreadLine}','${deleteTopologySpreadLine2}'d' ${thisFile}
       fi


       typeFrontend=$(grep -n "        type: frontend" ${thisFile})      

       if [[ -z ${typeFrontend} ]]; then
           labelLine=$(grep -n  "      labels:" ${thisFile} | cut -c 1-2)
           echo "labelLine:$labelLine"
           labelLine=$(expr $labelLine + 1)
           sed -i ${labelLine}'i \
        type: frontend' ${thisFile}
       fi

      kubectl apply -f ${thisFile}
done
