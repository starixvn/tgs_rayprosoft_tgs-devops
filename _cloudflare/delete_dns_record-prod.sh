#!/bin/bash
#### bash create_dns_record.sh game-test
url='https://api.cloudflare.com/client/v4/zones/0a097bb6db1ff1fa4b780c39909cc9e8/dns_records'
domain='.super777.casino'

echo "input:$1"

responseId=$(curl -X GET "${url}?name=$1${domain}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | length')

if [[ "${responseId}" == "0" ]]; then
	
  result=$(curl -X POST "${url}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$content'","proxied":false}')
	 
  echo "create result:${result}"
fi