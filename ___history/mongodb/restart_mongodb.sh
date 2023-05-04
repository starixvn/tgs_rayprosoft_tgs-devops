#!/bin/bash
mongodb=tgs-gp-manual
deployment=game-gamerecord-manualworkservice

aws docdb reboot-db-instance --db-instance-identifier $mongodb --region ap-northeast-1;

while true
do
    mongodb_status=$(aws docdb describe-db-instances --region ap-northeast-1\
       --db-instance-identifier $mongodb \
       --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' | jq -r '.[][1]');

        echo "mongodb_status=$mongodb_status";

        if [[ $mongodb_status == "available" ]]; then
           break;
        fi
    sleep 5;
done

kubectl rollout restart deploy $deployment -n prod

while true
do
    pods_status=$(kubectl get pods -n prod | grep $deployment | awk '{print $2,$3}')
    IFS=$'\n'
    ARRAY=($pods_status)
    len=${#ARRAY[@]}
    echo "length=$len"

    let running_count=0
    while [ $i -lt ${#ARRAY[@]} ]; do
        echo "$i==${ARRAY[$i]}"
        if [[ "${ARRAY[$i]}" == "1/1 Running"  ]]; then
            let running_count++
        fi
    done

    pods_count=$((len))
    echo "pods_count=$pods_count"
    echo "running_count=$running_count"

    if [[ $running_count == $pods_count ]]; then
        break;
    fi
    sleep 5
done