#!/bin/bash
response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0

# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
    read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
    zonename=${zone_array[1]/\"}
        echo "${zonename}=${zoneid}"

        response_purge=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/purge_cache" \
                 -H "X-Auth-Email: ${auth_email}" \
                 -H "X-Auth-Key: ${auth_key}" \
                 -H "Content-Type: application/json" \
                 --data '{"purge_everything":true}')
        echo ${response_purge}
done
