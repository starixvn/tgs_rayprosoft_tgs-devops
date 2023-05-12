#!/bin/bash
bucket_name=agent-test-v2
domain=*.wlgtop.com
region=us-east-1
bucket_result=$(aws s3 ls | awk '{print $3}' | grep $bucket_name | wc -l)

echo "bucket_result=$bucket_result"

if [[ $bucket_result != "0" ]]; then
    echo "$bucket_name is already existed."
    exit 1
fi

echo "$bucket_name does not exists "
create_bucket_result=$(aws s3 mb s3://$bucket_name | grep "make_bucket: $bucket_name" | wc -l)

if [[ $create_bucket_result != "1" ]]; then
    echo "create $bucket_name failed."
    exit 1
fi

echo "$bucket_name is created."


# 2. Enable public access to the bucket

echo "Enable public access to the bucket...."
aws s3api put-public-access-block \
    --bucket $bucket_name \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# 3. Update the bucket policy for public read access:

echo "Update the bucket policy for public read access....."
aws s3api put-bucket-policy \
  --bucket $bucket_name \
  --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
      {
          \"Sid\": \"PublicReadGetObject\",
          \"Effect\": \"Allow\",
          \"Principal\": \"*\",
          \"Action\": \"s3:GetObject\",
          \"Resource\": \"arn:aws:s3:::$bucket_name/*\"
      }
  ]
}"

# 4. Enable the s3 bucket to host an `index` and `error` html page
echo "Enable the s3 bucket to host an `index` and `error` html page"
aws s3 website "s3://$bucket_name" --index-document index.html --error-document index.html
#aws s3 sync directory-path "s3://$bucket_name"

#################################################################

echo "request certificate...."
cert_arn=$(aws acm request-certificate --region $region --validation-method DNS --domain-name $domain | jq -r .CertificateArn)
echo "$cert_arn"
sleep 5
cert_info=$(aws acm describe-certificate --region $region --certificate-arn $cert_arn)
echo "cert_info=$cert_info"
cname=$(echo $cert_info | jq -r .Certificate.DomainValidationOptions[0].ResourceRecord.Name)
cname_value=$(echo $cert_info | jq -r .Certificate.DomainValidationOptions[0].ResourceRecord.Value)

echo "CNAME:${cname/${domain:1}/}"
echo "CNAME_VALUE:$cname_value"


response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0


zone_result=""
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
        zonename=${zone_array[1]/\"}
#        echo "${zonename}=${zoneid}"

        IFS=''
        if [[ "${zonename}" == "${domain:2}" ]]; then
                echo "${zonename}=${zoneid}"
                echo "cname:${cname:0:length-1}"
                echo "cname_value:$cname_value"

                result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records" \
                   -H "X-Auth-Email: ${auth_email}" \
                   -H "X-Auth-Key: ${auth_key}" \
                   -H "Content-Type: application/json" \
                --data '{"type":"CNAME","name":"'${cname:0:length-1}'","content":"'${cname_value}'","proxied":false}')

                echo "${result}"
                break
        fi
done

$domain_alias=agent.wlgtop.com
$s3_url="$bucket_name.s3-website.ap-east-1.amazonaws.com"

sed -e 's/{{domain_alias}}/$$domain_alias/g' -e 's/{s3_url}/cat/g' -e 's/{acm_crn}/$cert_arn/g' create-dist-config-template.json > create-dist-config-$bucket_name.json

aws cloudfront create-distribution --distribution-config file://create-dist-config-$bucket_name.json