#!/bin/bash
# https://docs.gitlab.com/ee/user/admin_area/settings/import_export_rate_limits.html
# https://docs.gitlab.com/ee/api/project_import_export.html

export newtoken=glpat-5rsDEzU5xsxzai_qEgnu
list=$(aws s3 ls s3://tgs-dev-backup/gitlab/ | awk '{print $4}')

for file in $(echo $list); do
	echo $file
	echo ${file/.tar.gz/}

	aws s3 cp s3://tgs-dev-backup/gitlab/$file $file
	
	## note: namespace equal to path
	curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" --form "path=${file/.tar.gz/}" --form "namespace=tgs8" --form "overwrite=true" \
     --form "file=@./$file" "https://gitlab.com/api/v4/projects/import" | jq;
	 
	sleep 10;
done