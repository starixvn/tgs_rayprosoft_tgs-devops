#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule
zoneid=e5c37e050acbf7ca0de04c0b3eaec53f   #1388bet.io

echo ${data} | jq

#echo ${response} | jq '.result'

curl -X POST "https://api.cloudflare.com/client/v4/zones/e5c37e050acbf7ca0de04c0b3eaec53f/firewall/rules" \
				 -H "X-Auth-Email: infrastructure@rayprosoft.com" \
				 -H "X-Auth-Key: ea16209785cb4fa06858c5571ff5b8057840f" \
				 -H "Content-Type: application/json" \
				 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {36.234.19.51})","paused": false }}]'
				 
				 
				 
declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc" "mess888.com");

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
					
			response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
				 -H "X-Auth-Email: ${auth_email}" \
				 -H "X-Auth-Key: ${auth_key}" \
				 -H "Content-Type: application/json" \
				 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')
			echo "create result:"
			echo ${response_create_rule} | jq
	fi

response2=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/e5c37e050acbf7ca0de04c0b3eaec53f/firewall/rules" \
     -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
     -H "Content-Type: application/json" \
     --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')


echo "final result: ${response2}" | jq

