#!/bin/bash
url=
email=
apikey=

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
  echo "$0 has created already."
fi
