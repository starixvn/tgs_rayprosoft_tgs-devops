#!/bin/bash
# aws s3 ls  s3://tgs-staging-backup/backups/ | awk '{print $2}' | awk -F '/' '/\// {print $1}'
days_30=$(date -d '-30 days' +"%Y-%m-%d")
data=$(aws s3api list-objects-v2 --bucket "tgs-staging-backup" --query "Contents[?LastModified<='$days_30'].{key: Key, date: LastModified}" | jq -c '.[].key')

for p in $data;do
	echo $p;
	if [[ $p != "grafana/" ]]; then 
		aws 
	fi
	echo "========="
done

data=$(aws s3api list-objects-v2 --bucket "tgs-dev-backup" --query "Contents[?LastModified<='$days_30'].{key: Key, date: LastModified}" | jq -c '.[].key')

for p in $data;do
	echo $p;
	if [[ $p != "grafana/" ]]; then 
		aws 
	fi
	echo "========="
done

data=$(aws s3api list-objects-v2 --bucket "tgs-prod-backup" --query "Contents[?LastModified<='$days_30'].{key: Key, date: LastModified}" | jq -c '.[].key')

for p in $data;do
	echo $p;
	if [[ $p != "grafana/" ]]; then 
		aws 
	fi
	echo "========="
done


