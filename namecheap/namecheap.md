# namecheap 開發
https://www.namecheap.com/support/api/methods/


## production environment
#### login
https://ap.www.namecheap.com/
#### promotion code
https://www.namecheap.com/promos/coupons/

## sandbox environment
#### login
https://www.sandbox.namecheap.com/
#### promotion code
https://www.sandbox.namecheap.com/promos/coupons/


## api response

#### Domain name not available
```
<?xml version="1.0" encoding="utf-8"?>
<ApiResponse xmlns="http://api.namecheap.com/xml.response" Status="ERROR">
  <Errors>
    <Error Number="3031166">Domain name not available</Error>
  </Errors>
  <Warnings/>
  <RequestedCommand>namecheap.domains.create</RequestedCommand>
  <CommandResponse Type="namecheap.domains.create">
    <DomainCreateResult Domain="pcclubtam2.biz" Registered="false" ChargedAmount="0" DomainID="0" OrderID="2975852" TransactionID="18667948" WhoisguardEnable="false" FreePositiveSSL="false" NonRealTimeDomain="false"/>
  </CommandResponse>
  <Server>PHX01SBAPIEXT05</Server>
  <GMTTimeDifference>--4:00</GMTTimeDifference>
  <ExecutionTime>1.288</ExecutionTime>
</ApiResponse>
```
#### Parameter RegistrantStateProvince is Missing
```
<?xml version="1.0" encoding="utf-8"?>
<ApiResponse xmlns="http://api.namecheap.com/xml.response" Status="ERROR">
  <Errors>
    <Error Number="2010178">Parameter RegistrantStateProvince is Missing</Error>
  </Errors>
  <Warnings/>
  <RequestedCommand>namecheap.domains.create</RequestedCommand>
  <CommandResponse Type="namecheap.domains.create">
    <DomainCreateResult Registered="false" ChargedAmount="0" DomainID="0" OrderID="0" TransactionID="0" WhoisguardEnable="false" FreePositiveSSL="false" NonRealTimeDomain="false"/>
  </CommandResponse>
  <Server>PHX01SBAPIEXT06</Server>
  <GMTTimeDifference>--4:00</GMTTimeDifference>
  <ExecutionTime>0.043</ExecutionTime>
</ApiResponse>

```
#### create domain 成功
```
<?xml version="1.0" encoding="utf-8"?>
<ApiResponse xmlns="http://api.namecheap.com/xml.response" Status="OK">
  <Errors/>
  <Warnings/>
  <RequestedCommand>namecheap.domains.create</RequestedCommand>
  <CommandResponse Type="namecheap.domains.create">
    <DomainCreateResult Domain="pcclubtam2.biz" Registered="true" ChargedAmount="17.1600" DomainID="817153" OrderID="2975851" TransactionID="18667904" WhoisguardEnable="false" FreePositiveSSL="false" NonRealTimeDomain="false"/>
  </CommandResponse>
  <Server>PHX01SBAPIEXT06</Server>
  <GMTTimeDifference>--4:00</GMTTimeDifference>
  <ExecutionTime>9.062</ExecutionTime>
</ApiResponse>

```

#### Get Balance
```
<?xml version="1.0" encoding="utf-8"?>
<ApiResponse Status="OK" xmlns="http://api.namecheap.com/xml.response">
    <Errors />
    <Warnings />
    <RequestedCommand>namecheap.users.getbalances</RequestedCommand>
    <CommandResponse Type="namecheap.users.getBalances">
        <UserGetBalancesResult Currency="USD" AvailableBalance="35.20" AccountBalance="35.20" EarnedAmount="0.00" WithdrawableAmount="0.00" FundsRequiredForAutoRenew="0.00" />
    </CommandResponse>
    <Server>PHX01APIEXT02</Server>
    <GMTTimeDifference>--4:00</GMTTimeDifference>
    <ExecutionTime>0.009</ExecutionTime>
</ApiResponse>
```

## xmllint 取得屬性值

```
Status=$(xmllint --xpath '//ApiResponse/@Status' domain.xml)
ErrorMsg=$(xmllint --xpath '//ApiResponse/Errors/Error/text()' domain.xml)
Status=$(xmllint --xpath '//ApiResponse/@Status' balance.xml)
currency=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetBalancesResult/@Currency'  balance.xml)
balance=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetBalancesResult/@AvailableBalance'  balance.xml)

```

