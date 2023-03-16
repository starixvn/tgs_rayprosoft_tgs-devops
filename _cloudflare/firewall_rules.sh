#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule
## https://api.cloudflare.com/#firewall-rules-create-firewall-rules
response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc" "mess888.com");

# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
        zonename=${zone_array[1]/\"}
        echo "${zonename}=${zoneid}"

        if [[ ! ${arr[*]} =~ "${zonename}" ]]; then
                response_rule=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
                         -H "X-Auth-Email: ${auth_email}" \
                         -H "X-Auth-Key: ${auth_key}" \
                         -H "Content-Type: application/json")
                IFS=''
                rules=$(echo ${response_rule} | jq '.result' | jq '.[] .id')
                if [ -z "$rules" ]; then
                        echo "$zonename 未設定"
						
						response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
							 -H "X-Auth-Email: ${auth_email}" \
							 -H "X-Auth-Key: ${auth_key}" \
							 -H "Content-Type: application/json" \
							 --data '[{"action": "block","paused": false,"description": "Block Taiwan","filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {36.234.19.51})","paused": false }}]')
						echo "create result:"
                        echo ${response_create_rule} | jq
                else
                        echo "$zonename 已設定"
                        for rule_id in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id'); do
                                echo "ruleid=$rule_id"
                        done
                fi
        fi
done
