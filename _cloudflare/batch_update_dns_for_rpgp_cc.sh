#!/bin/bash
export zoneid=c6c8be8e9c04948f486101b1b994c09c  ## for rpgp.cc
export old_content="a94198ee04c6c4436b7055c94847d4d5-708152393.ap-east-1.elb.amazonaws.com"
export new_content="af6adba06797349589af25372ceaccec-111111111.ap-east-1.elb.amazonaws.com"

#esponse=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
#   -H "X-Auth-Email: ${auth_email}" \
#   -H "X-Auth-Key: ${auth_key}" \
#   -H "Content-Type: application/json")

declare -i index=0
declare -i dns_index=0
declare -i count=0

#for zoneid in $(echo ${response} | jq '.result' | jq -r '.[].id'); do

#       echo ${response} | jq '.result' | jq -r ".[${index}].name"
#       index=$((index+1))
#       dns_index=$((0))
#       echo "ZONE_ID=${zoneid}"

#       if [[  "${zoneid}" == "${rpgp_cc_id}" ]]; then
                dnsrecordResponse=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?content=${old_content}&per_page=1000" \
                        -H "X-Auth-Email: ${auth_email}" \
                        -H "X-Auth-Key: ${auth_key}" \
                        -H "Content-Type: application/json")

                #echo ${dnsrecordResponse} | jq '.result' | jq '.[]'

                for dnsid in $(echo ${dnsrecordResponse} | jq '.result' | jq -r '.[].id'); do
                        dnsname=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].name")
                        dnstype=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].type")
                        proxied=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].proxied")
                        content=$(echo ${dnsrecordResponse} | jq '.result' | jq -r ".[${dns_index}].content")
                        dns_index=$((dns_index+1))

                        echo "old_content=${old_content}"
                        echo "content: ${content}"
                        echo "                     "

                        if [[ "$content" == "$old_content" ]]; then
                            echo "dns_name: ${dnsname}"
                            echo "dns_proxied: ${proxied}"
                            echo "dnsid: ${dnsid}"
                            echo "content: ${content}"
                            echo "                     "

                            result=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records/${dnsid}" \
                                   -H "X-Auth-Email: ${auth_email}" \
                                   -H "X-Auth-Key: ${auth_key}" \
                                   -H "Content-Type: application/json" \
                            --data "{\"type\":\"${dnstype}\",\"name\":\"${dnsname}\",\"content\":\"${new_content}\",\"proxied\":${proxied}}")
                            echo ${result} | jq

                        fi
                        #result=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records/${dnsid}" \
                        #       -H "X-Auth-Email: ${auth_email}" \
                        #       -H "X-Auth-Key: ${auth_key}" \
						#       -H "Content-Type: application/json" \
                        #   --data "{\"type\":\"A\",\"name\":\"${dnsname}\",\"content\":\"${newcontent}\",\"proxied\":${proxied}}")
                        #echo ${result} | jq
                done
#       fi
#done
