#!/bin/bash
export token="0urb613nnL1aiyuKO_shCaCyfIPVhhXQhh3RKEaH"
export content=a623076e1f0af4e92bf1e10346ea9588-1009698690.ap-east-1.elb.amazonaws.com
export zoneid_srvptt="bde511632919d9a7ee0571f7b09c275f"
export newcontent=$1

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "Authorization: ${token}" \
    -H "Content-Type: application/json")

declare -i index=0
declare -i dns_index=0
declare -i count=0

dnsrecordResponse=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid_srvptt}/dns_records?content=${content}" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json")

#echo ${dnsrecordResponse} | jq '.result' | jq '.[]'

for dnsid in $(echo ${dnsrecordResponse} | jq '.result' | jq -r '.[].id'); do
    dnsname=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].name"):
    proxied=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].proxied")
    content=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].content")
    dnsname=${dnsname/.srvptt.com:/}
    dns_index=$((dns_index+1))
    
    echo "dns_name: ${dnsname}"
    echo "dns_proxied: ${proxied}"
    echo "dnsid: ${dnsid}"
    echo "content: ${content}"
    echo "============================"

    result=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid_srvptt}/dns_records/${dnsid}" \
                    -H "Authorization: Bearer $token" \
                    -H "Content-Type: application/json" \
              --data "{\"type\":\"CNAME\",\"name\":\"${dnsname}\",\"content\":\"${newcontent}\",\"proxied\":${proxied}}")
    echo ${result} | jq
    #let "dns_index++"
done