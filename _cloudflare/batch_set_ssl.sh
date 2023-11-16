#!/bin/bash
## https://developers.cloudflare.com/api/operations/zone-settings-change-ssl-setting
export token="0urb613nnL1aiyuKO_shCaCyfIPVhhXQhh3RKEaH"

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json")

declare -i index=0
declare -i dns_index=0
declare -i count=0

for zoneid in $(echo ${response} | jq '.result' | jq -r '.[].id'); do

        zone_name=$(echo ${response} | jq '.result' | jq -r ".[${index}].name")
        index=$((index+1))
        dns_index=$((0))
        echo "ZONE_NAME=${zone_name}"
    
        response2=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/ssl" \
                        -H "Authorization: Bearer ${token}" \
                        -H "Content-Type: application/json")
        
        echo ${response} | jq
         
        #if [[  "${zone_name}" == *"skalaslot"* ]]; then

                # echo "=====>  zone_name=${zone_name}"
                # patchResponse=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/ssl" \
                        # -H "X-Auth-Email: ${auth_email}" \
                        # -H "X-Auth-Key: ${auth_key}" \
                        # -H "Content-Type: application/json" \
                        # --data '{"value":"full"}')
                # echo ${patchResponse} | jq '.result' | jq '.[]'
        #fi
done

