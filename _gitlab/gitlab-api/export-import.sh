#!/bin/bash
## https://docs.gitlab.com/ee/api/projects.html
## https://stackoverflow.com/questions/31498473/gitlab-api-for-all-projects-under-group
## http://repositories.compbio.cs.cmu.edu/help/api/project_import_export.md
export token=oD2cksJhGN1tgUuaE6C9
export newtoken=glpat-5rsDEzU5xsxzai_qEgnu

ExecuteProjectList(){
    res=$(curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/groups/$1/projects?per_page=100&page=$2&sort=asc&order_by=name")
    count=0
    for id in $(echo $res | jq -r '.[].id'); do
        name=$(echo $res | jq -r ".[${count}].name")
        filename="${name}.tar.gz"
        let "count+=1"
        curl --request POST --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/projects/$id/export"
		sleep 30
        curl --header "PRIVATE-TOKEN: ${token}" --output "${filename}" "https://gitlab.com/api/v4/projects/$id/export/download"
		sleep 30
        aws s3 cp ${filename} s3://tgs-dev-backup/gitlab/
		
		curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" --form "path=${name}" --form "namespace=tgs8" --form "overwrite=true" \
     --form "file=@./${filename}" "https://gitlab.com/api/v4/projects/import" | jq;
    done
}

ExecuteProjectList 8800794 1
ExecuteProjectList 8800794 2
ExecuteProjectList 12042640 1

sudo rm -rf *.tar.gz 