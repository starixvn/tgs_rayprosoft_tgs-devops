# https://chat.chatbotapp.ai/chats/-O-41qSZqZTzb7LcSpAo?model=gpt-4o
# 设定变量
$ovpnFile = "C:\Users\lester.wei\OpenVPN\config\lester\lester.ovpn"
$tempFile = "C:\Users\lester.wei\OpenVPN\config\lester\template.ovpn"

# 您要添加路由的域名
$domains = @("rpgp.cc", "srvptt.com", "yydsgo.xyz")

# 获取域名的 IP 地址并生成路由规则
$routes = @()
foreach ($domain in $domains) {
    $ipAddresses = [System.Net.Dns]::GetHostAddresses($domain) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { $_.IPAddressToString }
    foreach ($ip in $ipAddresses) {
        $routes += "route $ip 255.255.255.255 vpn_gateway"
    }
}

# 读取现有的 .ovpn 文件并在 <ca> 标签后插入路由规则
$caTag = "<ca>"
$insertedRoutes = $false
Get-Content -Path $ovpnFile | ForEach-Object {
    if (-not $insertedRoutes -and $_ -eq $caTag) {
        # 插入生成的路由规则
        $routes | ForEach-Object { $_ }
        $insertedRoutes = $true
    }
    $_
} | Set-Content -Path $tempFile

# 替换原有的 .ovpn 文件
Move-Item -Path $tempFile -Destination $ovpnFile -Force

# 输出完成信息
Write-Host "已成功更新 $ovpnFile 包含如下路由规则:"
$routes | ForEach-Object { Write-Host $_ }