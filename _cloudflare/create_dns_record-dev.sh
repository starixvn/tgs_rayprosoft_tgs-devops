#!/bin/bash
#### bash create_dns_record.sh game-test
echo "input:$1"

response=$(curl -X GET "${url}?name=$1.rpgp.cc" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | length')

if [[ "${response}" == "0" ]]; then
  data=
  result=$(curl -X POST "${url}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'$1'","content":"220.132.206.70","proxied":false}')

  echo "create result:${result}"

else
  echo "$1 has created already."
fi