#!/bin/bash
## https://docs.gitlab.com/ee/api/projects.html
## https://stackoverflow.com/questions/31498473/gitlab-api-for-all-projects-under-group
## http://repositories.compbio.cs.cmu.edu/help/api/project_import_export.md
export token=oD2cksJhGN1tgUuaE6C9
export newtoken=glpat-5rsDEzU5xsxzai_qEgnu
export group="tgs2025"

GetGroupID() {
    local group_path=$1
    group_id=$(curl --silent --header "PRIVATE-TOKEN: ${newtoken}" "https://gitlab.com/api/v4/groups/${group_path}" | jq -r '.id')
    echo $group_id
}

DeleteGroup() {
    local group_id=$1
    response=$(curl --write-out "%{http_code}" --silent --output /dev/null --request DELETE --header "PRIVATE-TOKEN: ${newtoken}" "https://gitlab.com/api/v4/groups/${group_id}")
    
    if [ "$response" -eq 202 ]; then
        echo "Group ${group_id} has been scheduled for deletion."
    else
        echo "Failed to delete group ${group_id}. HTTP response code: $response"
    fi
}

# Function to count projects in a group
CountGroupProjects() {
    local group_id=$1
    local page=1
    local per_page=100
    local total_projects=0

    while true; do
        response=$(curl --silent --header "PRIVATE-TOKEN: ${token}" \
                        "https://gitlab.com/api/v4/groups/${group_id}/projects?per_page=${per_page}&page=${page}")
		message=$(echo $response | jq '.message')
		if message == "404 Group Not Found";then 
			break
		fi
						
        projects_count=$(echo $response | jq '. | length')
        total_projects=$((total_projects + projects_count))

        if [ "$projects_count" -lt "$per_page" ]; then
            break
        fi
        page=$((page + 1))
    done

    echo $total_projects
}

# Function to wait until there are no projects in the group
WaitForNoProjects() {
    local group_id=$1

    while true; do
        project_count=$(CountGroupProjects ${group_id})
        echo "Current number of projects in the group: ${project_count}"

        if [ "$project_count" -eq 0 ]; then
            echo "No projects left in the group."
            break
        fi

        echo "Waiting for projects to be deleted..."
        sleep 30 # Wait for 30 seconds before checking again
    done
}

CreateGroup() {
    local name="tgs"
    local path=$2
    local description="This is a new group"
    local visibility="private"

    response=$(curl --silent --write-out "%{http_code}" --output /dev/null \
                    --request POST --header "PRIVATE-TOKEN: ${token}" \
                    --data "name=${name}&path=${path}&description=${description}&visibility=${visibility}" \
                    "https://gitlab.com/api/v4/groups")

    if [ "$response" -eq 201 ]; then
        echo "Group '${name}' has been created successfully."
    else
        echo "Failed to create group '${name}'. HTTP response code: $response"
    fi
}


group_id=$(GetGroupID ${group})
echo "Group ID for path '${group_path}': ${group_id}"
DeleteGroup ${group_id}
WaitForNoProjects ${group_id}
CreateGroup "${group}"

ExecuteProjectList(){
    res=$(curl --header "PRIVATE-TOKEN: ${token}" "https://gitlab.com/api/v4/groups/$1/projects?per_page=100&page=$2&sort=asc&order_by=name")
    count=0
    for id in $(echo $res | jq -r '.[].id'); do
        name=$(echo $res | jq -r ".[${count}].name")
        filename="${name}.tar.gz"
        let "count+=1"
        curl --header "PRIVATE-TOKEN: ${token}" --output "${filename}" "https://gitlab.com/api/v4/projects/$id/export/download" &
		
        download_pid=$!
        last_size=0
        while kill -0 $download_pid 2>/dev/null; do
            current_size=$(stat -c%s "${filename}" 2>/dev/null || echo 0)
            if [[ $current_size -ne $last_size ]]; then
                echo "Downloading ${filename}: ${current_size} bytes"
                last_size=$current_size
            fi
            sleep 5
        done

        # Ensure download completes before proceeding
        wait $download_pid
		
		curl --request POST --header "PRIVATE-TOKEN: ${newtoken}" --form "path=${name}" --form "namespace=$group" --form "overwrite=true" \
     --form "file=@./${filename}" "https://gitlab.com/api/v4/projects/import" | jq;
    done
}

ExecuteProjectList 8800794 1
ExecuteProjectList 8800794 2
ExecuteProjectList 8800794 3
ExecuteProjectList 12042640 1

sudo rm -rf *.tar.gz 