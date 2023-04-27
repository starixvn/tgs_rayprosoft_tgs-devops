#!/bin/bash
export rpgp_cc_id=c6c8be8e9c04948f486101b1b994c09c

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

declare -i index=0
declare -i dns_index=0
declare -i count=0

for zoneid in $(echo ${response} | jq '.result' | jq -r '.[].id'); do

        zone_name=$(echo ${response} | jq '.result' | jq -r ".[${index}].name")
        index=$((index+1))
        dns_index=$((0))
        echo "ZONE_NAME=${zone_name}"

        #if [[  "${zone_name}" == *"skalaslot"* ]]; then

                echo "=====>  zone_name=${zone_name}"
                dnsrecordResponse=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/ipv6" \
                        -H "X-Auth-Email: ${auth_email}" \
                        -H "X-Auth-Key: ${auth_key}" \
                        -H "Content-Type: application/json" \
                        --data '{"value":"off"}')
                echo ${dnsrecordResponse} | jq '.result' | jq '.[]'
        #fi
done

