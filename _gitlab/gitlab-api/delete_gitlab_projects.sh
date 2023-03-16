#!/bin/bash
## https://docs.gitlab.com/ee/api/projects.html
## https://stackoverflow.com/questions/31498473/gitlab-api-for-all-projects-under-group
## http://repositories.compbio.cs.cmu.edu/help/api/project_import_export.md
export newtoken=glpat-5rsDEzU5xsxzai_qEgnu

DeleteProjectList(){
    res=$(curl --header "PRIVATE-TOKEN: ${newtoken}" "https://gitlab.com/api/v4/groups/$1/projects?per_page=100&page=$2&sort=asc&order_by=name")
    count=0
    for id in $(echo $res | jq -r '.[].id'); do
        name=$(echo $res | jq -r ".[${count}].name")
        let "count+=1"
        curl --request DELETE --header "PRIVATE-TOKEN: ${newtoken}" "https://gitlab.com/api/v4/projects/$id"
		sleep 2
        
    done
}

DeleteProjectList 60137880 


## for test
# curl --header "PRIVATE-TOKEN: glpat-5rsDEzU5xsxzai_qEgnu" "https://gitlab.com/api/v4/projects?per_page=100&page=1&sort=asc&order_by=name" | jq -r '.[].name'