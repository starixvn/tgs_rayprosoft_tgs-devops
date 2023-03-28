#!/bin/bash
#### bash create_dns_record.sh game-test
url=
email=''
apikey=''
prod_domain=''

echo "input:$1"

responseId=$(curl -X GET "${url}?name=$1.rpgp.cc" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | .[]  | select(.name == "'$1'.rpgp.cc").id')

responseType=$(curl -X GET "${url}?name=$1.rpgp.cc" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | .[]  | select(.name == "'$1'.rpgp.cc").type')

echo "responseId = ${responseId}" 
echo "responseType = ${responseType}"


if [[ "${responseId}" == "" ]]; then
	
  result=$(curl -X POST "${url}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$prod_domain'","proxied":false}')
	 
  echo "create result:${result}"
  
elif [[ "${responseType}" == "A" ]]; then
  result=$(curl -X PUT "${url}/${responseId}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$prod_domain'","proxied":false}')

  echo "update result:${result}"
fi
