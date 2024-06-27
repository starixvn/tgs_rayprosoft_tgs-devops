#!/bin/bash
## https://docs.gitlab.com/ee/api/projects.html
## https://docs.gitlab.com/ee/api/project_import_export.html
## https://docs.gitlab.com/ee/administration/settings/rate_limit_on_groups_api.html
## https://stackoverflow.com/questions/31498473/gitlab-api-for-all-projects-under-group
## http://repositories.compbio.cs.cmu.edu/help/api/project_import_export.md
export token=
export newtoken=
export group="Tgs$(date '+%Y%m%d%H%M')"

curl --request POST --header "PRIVATE-TOKEN: $newtoken" \
     --header "Content-Type: application/json" \
     --data '{"path": "$group", "name": "$group", "parent_id": 89540003}' \
     "https://gitlab.com/api/v4/groups/"
	 

DownloadFile() {
    local retries=$1
    local max_retries=10
    local sleep_time=65  # Initial sleep time

    # Download the file using curl
    curl --header "PRIVATE-TOKEN: ${token}" --output "${filename}" "https://gitlab.com/api/v4/projects/${id}/export/download"
    
    # Get the size of the downloaded file
    filesize=$(stat -c%s "${filename}")
    echo "${filename} => ${filesize} bytes"

    # Check if the filesize is less than the minimum threshold and if retries are less than the maximum retries allowed
    if [ "$filesize" -lt 100 ] && [ "$retries" -lt "$max_retries" ]; then
        sleep_time=$((65 + 20 * retries))  # Increase sleep time by 20 seconds for each retry
        echo "Sleeping for ${sleep_time} seconds before retrying..."
        sleep "$sleep_time"  # Wait for the calculated sleep time
        ((retries++))  # Increment the retry counter
        DownloadFile $retries  # Recursive call with the updated retry counter
    fi
}

ExecuteProjectList() {
    local group_id=$1
    local page=$2

    res=$(curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/groups/${group_id}/projects?per_page=100&page=${page}&sort=asc&order_by=name")
    count=0
    for id in $(echo $res | jq -r '.[].id'); do
        name=$(echo $res | jq -r ".[${count}].name")
        filename="${name}.tar.gz"
        let "count+=1"
        
        curl --request POST --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/projects/${id}/export"
        DownloadFile 0
        curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" --form "path=${name}" --form "namespace=$group" --form "overwrite=true" --form "file=@./${filename}" "https://gitlab.com/api/v4/projects/import" | jq
    done
}

ExecuteProjectList 8800794 1
ExecuteProjectList 8800794 2
ExecuteProjectList 8800794 3
ExecuteProjectList 12042640 1

sudo rm -rf *.tar.gz 