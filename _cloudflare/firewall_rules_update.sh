#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule
## https://api.cloudflare.com/#firewall-rules-create-firewall-rules

export token="0urb613nnL1aiyuKO_shCaCyfIPVhhXQhh3RKEaH"

DeleteFilters(){
	zone_id=$1
	zone_name=$2
	IFS=$'\n' ### important
	result=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$1/filters" \
		 -H "Authorization: Bearer $token" \
		 -H "Content-Type: application/json" | jq  -r '.result' | jq -r '.[] | .id')
	echo "result:${result}"
	for filter_id in ${result}; do

			respons_delete_filter=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/filters?id=${filter_id}" \
				 -H "Authorization: Bearer $token" \
				 -H "Content-Type: application/json")
			echo "delete result:"
			echo ${respons_delete_filter} | jq
	done
	
	echo "DeleteFilters: ${zone_name}"
}

CreateRule(){
	zone_id=$1
	response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zone_id}/firewall/rules" \
		 -H "Authorization: Bearer $token" \
		 -H "Content-Type: application/json" \
		 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'220.133.218.203' '114.33.41.237'})","paused": false }}]')

	echo ${response_create_rule}
}

UpdateRule(){
	zone_id=$1
	rule_id=$2
	filter_id=$3
	
	#test1 = '[{"id": \""$rule_id"\","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":\""${filter_id}"\","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]'
	#echo "test1:" 
	#echo "test1" | jq
	
	response_update_rule=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id}" \
		 -H "Authorization: Bearer $token" \
		 -H "Content-Type: application/json" \
		 --data '{"id": "'${rule_id}'","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":"'${filter_id}'","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}')
	echo ${response_update_rule}
}

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000&name=0063po.com" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "rpgp.cc" "yydsgo.xyz");
flag="false"
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
	IFS=','
	read -a zone_array <<< ${zone}
	zoneid=${zone_array[0]/\"}:
	zonename=${zone_array[1]/\"}
	zoneid="${zoneid/:/}"
	echo "${zonename}=${zoneid}"

	if [[ ! ${arr[*]} =~ "${zonename}" ]]; then
		#DeleteFilters ${zoneid} ${zonename}
	
		echo "zoneid=${zoneid}"
		response_rule=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
				 -H "Authorization: Bearer $token" \
				 -H "Content-Type: application/json")
				 
		#echo "rule response:"		 
		#echo ${response_rule}

		IFS=''
		rules=$(echo ${response_rule} | jq '.result' | jq '.[] .id')
		if [ -z "$rules" ]; then
			echo "$zonename 未設定"	
			CreateRuleResult=$(CreateRule ${zoneid})
			echo ${CreateRuleResult} | jq
		else
			echo "$zonename 已設定"
			
			for rule in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id+","+.description+","+.filter.id'); do
				IFS=','
				read -a zone_array <<< ${rule}
				rule_id=${zone_array[0]/\"}
				desc=${zone_array[1]/\"}
				filter_id=${zone_array[2]/\"}
				
				echo "rule_id=${rule_id//\"/}"
				echo "desc=${desc}"
				echo "filter_id=${filter_id}"
				
				if [[ ${desc} == "Block Taiwan" ]]; then 
					echo "Executing"				

					#####Update 沒作用#####
					#UpdateRuleResult=$(UpdateRule ${zoneid} ${rule_id} ${filter_id})
					
					#echo "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id}"

					#echo '{"id": "'${rule_id}'","action": "block","paused": false,"description": "Block Ta#iwan", "filter":{"id":"'${filter_id}'","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}' | jq

					# response_update_rule=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id}" \
						 # -H "X-Auth-Email: ${auth_email}" \
						 # -H "X-Auth-Key: ${auth_key}" \
						 # -H "Content-Type: application/json" \
						 # --data '{"id": "'${rule_id}'","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":"'${filter_id}'","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}')
					# echo ${response_update_rule}
					
					response_delete_rule=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}" \
					 -H "Authorization: Bearer $token" \
					 -H "Content-Type: application/json")
					echo "delete result:"
					echo ${response_delete_rule}
					
					CreateRuleResult=$(CreateRule ${zoneid})
			
					echo ${CreateRuleResult}
				fi
			done
		fi
	fi
done
