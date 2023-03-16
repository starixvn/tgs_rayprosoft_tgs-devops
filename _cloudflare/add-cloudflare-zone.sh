#!/bin/bash
CreateDnsRecord(){
        dns_record=$1
        zone_id=$2

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$2/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"CNAME","name":"'$1'","content":"'${content}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

CreateRule(){
	zone_id=$1
	response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json" \
		 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')

	echo ${response_create_rule}
}

declare -a arr=("atinbet.vip" "atinbet.club" "atinbet.app" "atinbet.net" "atinbet.org" "atingbet.com");

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json") 

#echo ${response} | jq '.result'

declare -i index=0

# FOR DELETE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
	IFS=','
    read -a zone_array <<< ${zone}
	zoneid=${zone_array[0]/\"}
    zonename=${zone_array[1]/\"}
	echo "${zoneid} ${zonename}"
	
	for new_domain in "${arr[@]}"
	do
	   if [[ "${new_domain}" == "${zonename}" ]]; then
		   echo $new_domain======$zonename
		   echo ${zoneid}
		url="https://api.cloudflare.com/client/v4/zones/${zoneid}"
		echo "url=${url}"

		result=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}" \
		     -H "X-Auth-Email: ${auth_email}" \
		     -H "X-Auth-Key: ${auth_key}" \
		     -H "Content-Type: application/json")
		echo "delete zone result:"
		echo "${result} | jq"
	   fi
	done
done

for zone in "${arr[@]}"; do
	echo ${zone}
	result_create_zone=$(curl -X POST "https://api.cloudflare.com/client/v4/zones" \
	     -H "X-Auth-Email: ${auth_email}" \
	     -H "X-Auth-Key: ${auth_key}" \
	     -H "Content-Type: application/json" \
	     --data "{\"name\":\"${zone}\",\"account\":{\"id\":\"${account_id}\"},\"jump_start\":false,\"type\":\"full\"}")
	echo "result_create_zone:"
	echo ${result_create_zone}

	zoneid=$(echo ${result_create_zone} | cut -c18-49)
	 
	result_automatic_https_rewrites=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/automatic_https_rewrites" \
		 -H "X-Auth-Email: ${auth_email}" \
	     -H "X-Auth-Key: ${auth_key}" \
	     -H "Content-Type: application/json" \
		--data "{\"value\":\"on\"}")
	 
	echo "result_automatic_https_rewrites:"
	echo ${result_automatic_https_rewrites} 
	 
	result_always_use_https=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/always_use_https" \
		 -H "X-Auth-Email: ${auth_email}" \
	     -H "X-Auth-Key: ${auth_key}" \
	     -H "Content-Type: application/json" \
		--data "{\"value\":\"on\"}")
	
	echo "result_always_use_https:"
	echo ${result_always_use_https}
	 
	result_minify=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/minify" \
		-H "X-Auth-Email: ${auth_email}" \
	    -H "X-Auth-Key: ${auth_key}" \
	    -H "Content-Type: application/json" \
		--data "{\"value\":{\"css\":\"on\",\"html\":\"on\",\"js\":\"on\"}}")
	 
	echo "result_minify:"
	echo ${result_minify}
	
	result_brotli=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/brotli" \
		-H "X-Auth-Email: ${auth_email}" \
	    -H "X-Auth-Key: ${auth_key}" \
	    -H "Content-Type: application/json" \
		 --data '{"value":"on"}')
		 
	echo "result_brotli:"
	echo ${result_brotli}

	response_firewall_rules=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json" \
		 --data '[{"action": "block","paused": false,"description": "Block Taiwan","filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {220.132.206.70})","paused": false }}]')

	echo "response_firewall_rules:"
	echo ${response_firewall_rules}
	
	result_dns_records_list = $(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?page=1&per_page=100&order=type&direction=desc&match=all" \
	 -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
	 -H "Content-Type: application/json")

	# FOR DELETE DNS
	for dns_id in $(echo ${result_dns_records_list} | jq '.result' | jq  '.[] | .id'); do
		result_dns_delete=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records/${dns_id}" \
				-H "X-Auth-Email: ${auth_email}" \
				-H "X-Auth-Key: ${auth_key}" \
				-H "Content-Type: application/json")
		echo "delete result:"
		echo $result_dns_delete
	done
	
	dns_record_result=$(CreateDnsRecord ${zone} ${zoneid})
	echo "dns_record_result:"
	echo ${dns_record_result}
	dns_record_result=$(CreateDnsRecord "www" ${zoneid})
	echo "dns_record_result:"
	echo ${dns_record_result}
	
	# FOR DELETE FIREWALL RULES
	for rule_id in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id'); do
			echo "ruleid=${rule_id//\"/}"
			response_delete_rule=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}" \
				 -H "X-Auth-Email: ${auth_email}" \
				 -H "X-Auth-Key: ${auth_key}" \
				 -H "Content-Type: application/json" \
				 --data '{}')
			echo "delete result:"
			echo ${response_delete_rule} | jq
	done
	
	CreateRuleResult=$(CreateRule ${zoneid})
	
	echo ${CreateRuleResult} | jq
done
