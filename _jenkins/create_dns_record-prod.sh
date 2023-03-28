#!/bin/bash
url=
email=
apikey=
content=
domain=

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
else
  echo "$1 has created already."
fi

