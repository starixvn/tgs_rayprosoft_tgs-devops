# https://chat.chatbotapp.ai/chats/-O-41qSZqZTzb7LcSpAo?model=gpt-4o
# 创建一个新的任务定义
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"C:\path\to\update_ovpn.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 3am  # 例如，每天凌晨 3 点运行。您可以根据需求调整时间。
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest  # 以系统权限运行
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# 任务注册信息
$taskName = "UpdateOpenVPNRoutes"
$description = "A scheduled task to update OpenVPN routes based on domain name resolution."

# 创建新的计划任务
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName $taskName -Description $description

Write-Host "Task Scheduler entry '$taskName' has been created successfully."
