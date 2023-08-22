#!/bin/bash
DomainName=$1
Nameservers=armando.ns.cloudflare.com,maleah.ns.cloudflare.com
ApiUser=pokely1224
UserName=pokely1224
ApiKey=5577887301ae4e609015ec7cd5e59328
ClientIp=114.33.41.237
Address="Sec4WenxinRdBeitunDist"
NameCheapUrl="https://api.namecheap.com/xml.response?"
Email=ly.lester@rayprosoft.com
#TelegramChatId="-1001985229002"
#TelegramChatId="-866679594"
TelegramChatId=$2
TelegramToken="6137223098:AAEeQiBaQ1G1Gj5pO7p9q_FVwvXViM1BMcg"

if [[ $3 != "" ]]; then
  Nameservers=$3
fi

## https://www.namecheap.com/promos/coupons/
IFS='.' read -r -a array <<< "$DomainName"
TLD="${array[1]}"
SLD="${array[0]}"

Url="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
DomainName=$DomainName&\
Command=namecheap.domains.dns.setCustom&\
ClientIp=$ClientIp&\
SLD=$SLD&\
TLD=$TLD&\
Nameservers=$Nameservers"

echo "Url=$Url"

response=$(curl -X GET $Url -H "Content-Type: application/xml" -d '')
echo $response | xmllint --format - > changens.xml
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' changens.xml

Status=$(xmllint --xpath '//ApiResponse/@Status' changens.xml)

Message=""

if [[ "$Status" == *"OK"* ]]; then
    read -r -d '' Message <<EOT
    修改nameserver: $DomainName 成功
NameServers: $Nameservers
EOT

else
    ErrorMsg=$(xmllint --xpath '//ApiResponse/Errors/Error/text()' changens.xml)
    read -r -d '' Message <<EOT
    修改nameserver: $DomainName 失敗
原因: $ErrorMsg
NameServers: $Nameservers
EOT

fi

curl -s --data-urlencode "text=$Message" --data "chat_id=$TelegramChatId" "https://api.telegram.org/bot$TelegramToken/sendMessage" > /dev/null
