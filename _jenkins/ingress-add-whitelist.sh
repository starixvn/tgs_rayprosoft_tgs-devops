#!/bin/bash
ingressfile="/var/lib/jenkins/ingress-payment.yaml"
kubectl -n prod get ing ingress-payment -o yaml > $ingressfile
ip=$1
grep -n  "deny all;" $ingressfile | while read -r KeyLines;do  ## using tac to change sort order
        echo "line=$KeyLines"
        res=$(echo "${KeyLines/:      deny all;/}")
        insertLine=$(expr $res)

        echo "insertLine=$insertLine"

        if [ ! -z "$insertLine" ] ##&& [ $(($insertLine)) -gt 10  ]
        then
            echo "insertLine2=${insertLine}"
            sed -i "${insertLine} i\
\ \ \ \ \ \ allow $ip/32;" $ingressfile
            kubectl apply -f $ingressfile
        fi
done
