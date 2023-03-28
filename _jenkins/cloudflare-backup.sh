#!/bin/bash
auth_email=
auth_key=
account_id=
content=
filename="./cloudflare-$(date +%Y-%m-%d).json"
file_to_delete="cloudflare-$(date -d "31 days ago" +"%Y-%m-%d").json"

GetDNS() {
        zone_id=$1
        IFS=''
        dnsresult=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$1/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json")

#       echo ${result} | jq
        result="\"dns\":["
        dns=""
        IFS=$'\n'

        for record in $(echo ${dnsresult} | jq '.result' | jq -r '.[] | @base64'); do
                _jq() {
                        echo ${record} | base64 --decode | jq -r ${1}
                }
                dnsname=$(_jq '.name')
                dnstype=$(_jq '.type')
                dnsproxied=$(_jq '.proxied')
                dnscontent=$(_jq '.content')
                dnsid=$(_jq '.id')

            dns+=$(printf '{"id":"%s","name":"%s","type":"%s","proxied":"%s","content":"%s"}' "${dnsid}" "${dnsname}" "${dnstype}" "${dnsproxied}" "${dnscontent}")
            dns+=","

        done
        result+="${dns::-1}"
        result+="],"
        echo ${result}
}

GetFirewareRules() {
        zone_id=$1
        IFS=''
        ruleresult=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$1/firewall/rules" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json")

        #echo ${result} | jq
        result="\"firewall_rules\":[" >> ${filename}
        rules=""
        IFS=$'\n'
        for record in $(echo ${ruleresult} | jq '.result' | jq -r '.[] | @base64'); do
                _jq() {
                        echo ${record} | base64 --decode | jq -r ${1}
                }
                rule_desc=$(_jq '.description')
                rule_paused=$(_jq '.paused')
                rule_action=$(_jq '.action')
                rule_filter=$(_jq '.filter.expression')
                rule_id=$(_jq '.id')

            rules+=$(printf '{"id":"%s","desc":"%s","action":"%s","paused":"%s","filter":"%s"}' "${rule_id}" "${rule_desc}" "${rule_action}" "${rule_paused}" "${rule_filter//\"/\\\"}")

	     rules+=","

        done
        result+="${rules::-1}"
        result+="]"
        echo ${result}
}


response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0
echo "[" > ${filename}

zone_result=""
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
        zonename=${zone_array[1]/\"}
        echo "${zonename}=${zoneid}"

        IFS=''
        #if [[ "${zonename}" == "1388bet.io" || "${zonename}" == "rpgp.cc" ]]; then
                zone_result+="{"
                zone_result+="\"zoneid\":\"${zoneid}\","
                zone_result+="\"zonename\":\"${zonename}\","

                dns_result=$(GetDNS ${zoneid})
                firewall_result=$(GetFirewareRules ${zoneid})

                zone_result+=${dns_result}
                zone_result+=${firewall_result}
                zone_result+="},"
        #fi
done
echo "${zone_result::-1}" >> ${filename}
echo "]" >> ${filename}

#cat ${filename} | jq
aws s3 rm  s3://tgs-dev-backup/cloudflares/${file_to_delete}
aws s3 cp ${filename} s3://tgs-dev-backup/cloudflares/

rm ${filename}
