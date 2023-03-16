#!/bin/bash
for p in $(kubectl get deploy -n prod | grep agent-28bet | awk '{print $1}'); do
        DeployFile="${p}.yaml"
        kubectl -n prod get deploy $p -o yaml > ${DeployFile};

        if [[ $p != "agent-api" ]]
        then
                echo $p
                count=0
                grep -n  "resources:" ${DeployFile} | grep -v "f:" | while read -r KeyLines;do  ## using tac to change sort orde
                        count=$((count+1))
                        echo "count=${count}"
                        echo "line=$KeyLines"
                        res=$(echo "${KeyLines/:        resources:/}")
                        insertLine=$(expr $res + 1)
                        endLine=$(expr $res + 6)
                        echo "insertLine=$insertLine"

                        echo "========"
                        sed -i "${insertLine},${endLine}d"  ${DeployFile}

                        sed -i ${insertLine}'i \
          limits:\
            cpu: 100m\
            memory: 200Mi\
          requests:\
            cpu: 10m\
            memory: 20Mi' ${DeployFile}

                kubectl apply -f ${DeployFile}
                done
        fi
done
