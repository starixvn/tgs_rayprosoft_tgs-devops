#!/bin/bash
kubectl -n prod get ing ingress-payment -o yaml > ingress-payment.yaml
ip=$1
grep -n  "deny all;" ingress-payment.yaml | while read -r KeyLines;do  ## using tac to change sort order
        echo "line=$KeyLines"
        res=$(echo "${KeyLines/:      deny all;/}")
        insertLine=$(expr $res)

        echo "insertLine=$insertLine"

        if [ ! -z "$insertLine" ] ##&& [ $(($insertLine)) -gt 10  ]
        then
            echo "insertLine2=${insertLine}"
            sed -i "${insertLine} i\
\ \ \ \ \ \ allow $ip/32;" ingress-payment.yaml
			kubectl apply -f ingress-payment.yaml
        fi
done
