#!/bin/bash
#### bash tgs-devops/terraform/install-infra/create_dns_record-staging.sh a33294a5cf54543129086da3543f721d-1416873855.ap-east-1.elb.amazonaws.com
#### bash tgs-devops/terraform/install-infra/create_dns_record-staging.sh $lbname
export auth_email=infrastructure@rayprosoft.com
export auth_key=ea16209785cb4fa06858c5571ff5b8057840f
export account_id=bca33f2713e936cee007fa34f24a773f
export zone_id=c6c8be8e9c04948f486101b1b994c09c ## rpgp.cc
export old_staging_dns=ae8e197bdf6b94b7b815ed951973817e-741969300.ap-east-1.elb.amazonaws.com

url='https://api.cloudflare.com/client/v4/zones/c6c8be8e9c04948f486101b1b994c09c/dns_records'

#prod_domain='a6c1116e0e2dc481981b9b39d0283c43-383156902.ap-east-1.elb.amazonaws.com'
export key=stg2-
export new_content=$1

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

for zone in $(echo ${response} | jq '.result' | jq  '.[] | .content+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        content=${zone_array[0]}
        IFS=' '
        read -a zone_array2 <<< ${content}
        content=${zone_array2[0]}
        content=${content/\"/}
        name=${zone_array2[1]}
        name=${name/\"/}
        echo "zone=${zone}"
        echo "content=${content}"
        echo "name=${name}"

        if [[ $content == "${old_staging_dns}" ]]; then

                new_name=""
                if [[ $name =~ ^stg* ]]; then
                        new_name=${name/stg-/${key}}
                else
                        new_name="${key}${name}"
                fi
                new_name=${new_name/.rpgp.cc/}
                echo "new_name=${new_name}"
                echo '{"type":"CNAME","name":"'${new_name}'","content":"'$new_content'","proxied":true}'

                result=$(curl -X POST "${url}" \
                 -H "X-Auth-Email: ${auth_email}" \
                 -H "X-Auth-Key: ${auth_key}" \
                 -H "Content-Type: application/json" \
                 --data '{"type":"CNAME","name":"'${new_name}'","content":"'$new_content'","proxied":true}')

                echo $result | jq
        fi
        echo "==================="
done