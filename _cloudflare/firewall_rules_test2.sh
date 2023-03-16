#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule

echo ${data} | jq
{response} | jq '.result'		 

DeleteFilters(){
	zone_id=$1
	zone_name=$2
	result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$1/filters" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json")

	IFS=''
	filters=$(echo ${result} | jq '.result' | jq '.[] .id')
	
	for filter_id in $(echo ${result} | jq '.result' | jq  '.[] | .id'); do
			echo "ruleid=${rule_id//\"/}"
			respons_delete_filter=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/filters/id=${filter_id//\"/}" \
				 -H "X-Auth-Email: ${auth_email}" \
				 -H "X-Auth-Key: ${auth_key}" \
				 -H "Content-Type: application/json")
			echo "delete result:"
			echo ${respons_delete_filter} | jq
	done
	
	echo "DeleteFilters: ${zone_name}"
}

				 
declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc" "mess888.com");


    response_rule=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
                         -H "X-Auth-Email: ${auth_email}" \
                         -H "X-Auth-Key: ${auth_key}" \
                         -H "Content-Type: application/json")
	IFS=''
	
	echo ${response_rule} | jq
	
	rules=$(echo ${response_rule} | jq '.result' | jq '.[] .id')
	if [ -z "$rules" ]; then
			echo "$zonename 未設定"			
			
			echo "data:"
			echo '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]' | jq
			
			response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
				 -H "X-Auth-Email: ${auth_email}" \
				 -H "X-Auth-Key: ${auth_key}" \
				 -H "Content-Type: application/json" \
				 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')
			echo "create result:"
			echo ${response_create_rule} | jq
	else
			echo "$zonename 已設定"
			
			echo ${response_rule} | jq
			
			for rule_id in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id'); do
					echo "ruleid=${rule_id//\"/}"
					
					echo "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}"
					
					response_delete_rule=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}" \
						 -H "X-Auth-Email: ${auth_email}" \
						 -H "X-Auth-Key: ${auth_key}" \
						 -H "Content-Type: application/json" \
						 --data '{}')
					echo "delete result:"
					echo ${response_delete_rule} | jq
			done
	fi