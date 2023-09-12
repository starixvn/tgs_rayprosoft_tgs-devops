#!/bin/bash
export token="0urb613nnL1aiyuKO_shCaCyfIPVhhXQhh3RKEaH"

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000&name=rpgp.cc" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json") 

declare -i index=0
declare -i dns_index=0
declare -i count=0

for zoneid in $(echo ${response} | jq '.result' | jq -r '.[].id'); do

	echo ${response} | jq '.result' | jq -r ".[${index}].name"
	index=$((index+1))
	dns_index=$((0))
	echo "ZONE_ID=${zoneid}"
	
	if [[  "${zoneid}" == "${rpgp_cc_id}" ]]; then 
		dnsrecordResponse=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?content=${content}" \
			-H "X-Auth-Email: ${auth_email}" \
			-H "X-Auth-Key: ${auth_key}" \
			-H "Content-Type: application/json")

		#echo ${dnsrecordResponse} | jq '.result' | jq '.[]'

		for dnsid in $(echo ${dnsrecordResponse} | jq '.result' | jq -r '.[].id'); do 
			dnsname=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].name")
			proxied=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].proxied") 
			
			dns_index=$((dns_index+1))
			echo "dns_name: ${dnsname}" 
			echo "dns_proxied: ${proxied}"
			echo "dnsid: ${dnsid}"

			result=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records/${dnsid}" \
				-H "X-Auth-Email: ${auth_email}" \
				-H "X-Auth-Key: ${auth_key}" \
				-H "Content-Type: application/json" \
			   --data "{\"type\":\"A\",\"name\":\"${dnsname}\",\"content\":\"${newcontent}\",\"proxied\":${proxied}}")
			echo ${result} | jq 
		done
	fi
done
	 
