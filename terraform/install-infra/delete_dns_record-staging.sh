#!/bin/bash
#### bash tgs-devops/terraform/install-infra/delete_dns_record.sh

export auth_email=infrastructure@rayprosoft.com
export auth_key=ea16209785cb4fa06858c5571ff5b8057840f
export account_id=bca33f2713e936cee007fa34f24a773f
export zone_id=c6c8be8e9c04948f486101b1b994c09c ## rpgp.cc

export old_staging_dns=ae8e197bdf6b94b7b815ed951973817e-741969300.ap-east-1.elb.amazonaws.com

url='https://api.cloudflare.com/client/v4/zones/c6c8be8e9c04948f486101b1b994c09c/dns_records'
#prod_domain='a6c1116e0e2dc481981b9b39d0283c43-383156902.ap-east-1.elb.amazonaws.com'
export key=stg2-
new_content=$1

response=$(curl -X GET "${url}?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

for zone in $(echo ${response} | jq '.result' | jq  '.[] | .content+","+.name+","+.id'); do
        IFS=','
        read -a zone_array <<< ${zone}
        content=${zone_array[0]/\"}
        IFS=' '
        read -a zone_array2 <<< ${content}
        content=${zone_array2[0]}
        name=${zone_array2[1]/\"}
        id=${zone_array2[2]/\"}

        echo "content=${content}"
        echo "name=${name}"
        echo "id=$id"

        if [[ $name =~ "${key}" ]] ; then
                result=$(curl -X DELETE "${url}/${id}" \
                 -H "X-Auth-Email: ${auth_email}" \
                 -H "X-Auth-Key: ${auth_key}" \
                 -H "Content-Type: application/json")
                echo $result | jq
        fi
        echo "==================="
done