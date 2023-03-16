## https://docs.gitlab.com/ee/api/projects.html
## https://stackoverflow.com/questions/31498473/gitlab-api-for-all-projects-under-group

export token=oD2cksJhGN1tgUuaE6C9 


curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/namespaces" | jq

curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/groups/8800794" | jq


curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/groups/8800794/projects?per_page=100&page=0&sort=asc&order_by=name" | jq .[] | jq .name
 


## 	https://gitbook.curiouser.top/origin/gitlab-backuprestore.html


curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/projects/20478010/export"

curl --header "PRIVATE-TOKEN: ${token}" --output turngamesystem.tar.gz "https://gitlab.com/api/v4/projects/20478010/export/download"
	 
	 
	
curl --request POST --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/projects/20478010/export" \
    --data "upload[http_method]=PUT" \
    --data-urlencode "upload[url]=https://tgs-dev-backup.s3.ap-east-1.amazonaws.com/gitlab"



aws s3 cp $JENKINS_BACKUP_FILE s3://tgs-dev-backup/gitlab/


lunyi.lester@gmail.com  token
glpat-4sU3AGN8EsNuDe9a8nYX


export newtoken=glpat-4sU3AGN8EsNuDe9a8nYX 


## https://docs.gitlab.com/ee/api/projects.html#create-project

## create a new project
curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" \
     --header "Content-Type: application/json" --data '{
        "name": "turnkey-gaming-system", "path": "turnkey-gaming-system"}' \
     --url 'https://gitlab.com/api/v4/projects/' | jq
	
## import an new project
curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" --form "path=turnkey-gaming-system" \
     --form "file=@./Tgs.Bo-Api.tar.gz" "https://gitlab.com/api/v4/projects/import" | jq


## transfer 
## https://datascience.blog.wzb.eu/2022/02/22/batch-transfer-gitlab-projects-with-the-gitlab-api/
## Only used for internal group 

curl --request PUT --header "PRIVATE-TOKEN: ${token}" \
     "https://gitlab.com/api/v4/projects/20478010/transfer?namespace=59978551"
	 