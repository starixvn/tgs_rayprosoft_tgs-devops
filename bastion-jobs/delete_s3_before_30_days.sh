#!/bin/bash
# aws s3 ls  s3://tgs-staging-backup/backups/ | awk '{print $2}' | awk -F '/' '/\// {print $1}'
days_30=$(date -d '-30 days' +"%Y-%m-%d")
buckets=("tgs-dev-backup" "tgs-staging-backup" "tgs-prod-backup")

echo "buckets=${buckets[@]}"

for bucket in "${buckets[@]}"; do 
	data=$(aws s3api list-objects-v2 --bucket ${bucket} --query "Contents[?LastModified<='$days_30'].{key: Key, date: LastModified}" | jq -c '.[].key')

	for p in $data;do
		p=$(echo $p | sed 's/\"//g')
		if [[ $p != "grafana/" ]]; then 
			aws s3 rm s3://${bucket}/$p
			echo "s3://${bucket}/$p"
		fi
		echo "========="
	done
done

