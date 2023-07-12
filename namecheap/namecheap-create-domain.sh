#!/bin/bash
function getCouponCode(){
    echo $(curl "https://www.namecheap.com/promos/coupons/") > coupon.html
    echo $(xmllint --html -xpath "/html/body/fragment[2]/*/div/div/section[2]/div/div/div/div[1]/div/div[2]/div/div[1]/button/text()"  coupon.html)
}
DomainName=$1
Address="Sec4WenxinRdBeitunDist"
NameCheapUrl="https://api.sandbox.namecheap.com/xml.response?"
PromotionCode=$(getCouponCode)
Url="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
DomainName=$DomainName&\
Command=namecheap.domains.create&\
ClientIp=$ClientIp&\
Years=1&\
AuxBillingFirstName=Mark&\
AuxBillingLastName=Wu&\
AuxBillingAddress1=$Address&\
AuxBillingStateProvince=TW&\
AuxBillingPostalCode=406&\
AuxBillingCountry=TW&\
AuxBillingPhone=+886.6613102107&\
AuxBillingEmailAddress=hank.wu@rayprosoft.com&\
AuxBillingOrganizationName=Raypro&\
AuxBillingCity=TC&\
TechFirstName=Mark&\
TechLastName=Wu&\
TechAddress1=$Address&\
TechStateProvince=TW&\
TechPostalCode=90045&\
TechCountry=TW&\
TechPhone=+886.6613102107&\
TechEmailAddress=hank.wu@rayprosoft.com&\
TechOrganizationName=Raypro&\
TechCity=TW&\
AdminFirstName=Mark&\
AdminLastName=Wu&\
AdminAddress1=$Address&\
AdminStateProvince=CA&\
AdminPostalCode=9004&\
AdminCountry=US&\
AdminPhone=+886.6613102107&\
AdminEmailAddress=hank.wu@rayprosoft.com&\
AdminOrganizationName=Raypro&\
AdminCity=CA&\
RegistrantFirstName=Mark&\
RegistrantLastName=Wu&\
RegistrantAddress1=$Address&\
RegistrantStateProvince=TW&\
RegistrantPostalCode=406&\
RegistrantCountry=TW&\
RegistrantPhone=+886.6613102107&\
RegistrantEmailAddress=hank.wu@rayprosoft.com&\
RegistrantOrganizationName=Raypro&\
RegistrantCity=TW&\
Nameservers=$Nameservers"

echo $Url >> namecheap.log

response=$(curl -X POST $Url -H "Content-Type: application/xml" -d '')
echo $response | xmllint --format - > domain.xml
echo $response | xmllint --format - >> namecheap.log
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' domain.xml
#################
## get balance ##
#################
balance_request_url="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
Command=namecheap.users.getBalances&\
ClientIp=$ClientIp"

balance_response=$(curl -X POST $balance_request_url -H "Content-Type: application/xml" -d '')
echo $balance_response | xmllint --format - > balance.xml
echo $balance_response | xmllint --format - >> namecheap.log
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' balance.xml

######################
## Message Process  ##
######################

Status=$(xmllint --xpath '//ApiResponse/@Status' domain.xml)
ErrorMsg=$(xmllint --xpath '//ApiResponse/Errors/Error/text()' domain.xml)
ChargeAmount=$(xmllint --xpath '//ApiResponse/CommandResponse/DomainCreateResult/@ChargedAmount' domain.xml)
currency=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetBalancesResult/@Currency'  balance.xml)
balance=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetBalancesResult/@AvailableBalance'  balance.xml)
balance=$(echo ${balance/AvailableBalance=/})
charge=$(echo ${ChargeAmount/ChargedAmount=/})

echo "balance:$balance"
echo "status:$Status"

Message=""

if [[ "$Status" == *"OK"* ]]; then

    read -r -d '' Message <<EOT
    建立Domain: $DomainName 成功
優惠碼: $PromotionCode
費用: $charge
餘額: $balance
EOT

else
    read -r -d '' Message <<EOT
    建立Domain: $DomainName 失敗
優惠碼: $PromotionCode
原因: $ErrorMsg
餘額: $balance
EOT

fi

curl -s --data-urlencode "text=$Message" --data "chat_id=$TelegramChatId" "https://api.telegram.org/bot$TelegramToken/sendMessage" > /dev/null
