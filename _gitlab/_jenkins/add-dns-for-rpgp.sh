prod_content=
staging_content=
#!/bin/bash
auth_email=
auth_key=
account_id=
prod_content=
staging_content=
officeip=
rpgp_cc_zone_id=
srvptt_com_zone_id=


CreateProdDnsRecord(){
        dns_record=$1
        zone_id=$srvptt_com_zone_id

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"CNAME","name":"'$1'.srvptt.com","content":"'${prod_content}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

CreateStagingDnsRecord(){
        dns_record=$1
        zone_id=$rpgp_cc_zone_id

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"CNAME","name":"'$1'.rpgp.cc","content":"'${staging_content}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

CreateDevDnsRecord(){
        dns_record=$1
        zone_id=$rpgp_cc_zone_id

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"A","name":"'$1'.rpgp.cc","content":"'${officeip}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

if [[ $1 == "prod" ]]; then 
	dns_record_result=$(CreateProdDnsRecord $2)
	echo "dns_record_result:"
	echo ${dns_record_result}
elif [[ $1 == "staging" ]]; then 
	dns_record_result=$(CreateStagingDnsRecord $2)
	echo "dns_record_result:"
	echo ${dns_record_result}
else 
	dns_record_result=$(CreateDevDnsRecord $2)
	echo "dns_record_result:"
	echo ${dns_record_result}
fi

