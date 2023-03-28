#!/bin/bash
export auth_email=
export auth_key=
export account_id=
export zoneid=
export filterid=

ip=$1

result=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/filters/$filterid" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json")

echo $result | jq -r .result

result=$(echo $result | jq -r .result)
request=${result/\})/ $ip\})};

echo "request"
echo "$request" | jq

result2=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/filters/$filterid" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
                         --data "$request")

echo $result2 | jq -r .result

