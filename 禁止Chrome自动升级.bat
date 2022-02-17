@echo off
PUSHD %~DP0 & cd /d "%~dp0"
%1 %2
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :runas","","runas",1)(window.close)&goto :eof
:runas

echo $computer="%cname%" > "%temp%\test.ps1"
for /f "delims=:" %%i in ('findstr /n "^:JoinDomain$" "%~f0"') do (
	more +%%i "%~f0" >> "%temp%\test.ps1"
)

powershell -executionpolicy remotesigned -file "%temp%\test.ps1"
pause
:JoinDomain

if ([Environment]::Is64BitOperatingSystem -eq "True") {
    #Write-Host "64-bit OS"
    $PF=${env:ProgramFiles(x86)}
}
else {
    #Write-Host "32-bit OS"
    $PF=$env:ProgramFiles
}

if ($(Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") -eq "true") {
    # 结束进程
    taskkill /im chrome.exe /f
    taskkill /im GoogleUpdate.exe /f
    # Google Chrome 更新服务
    #这里也可以使用 sc.exe stop "service name"
    Stop-Service -Name "gupdate"
    Stop-Service -Name "gupdatem"
    Stop-Service -Name "GoogleChromeElevationService"
    # Windows 10 默认 PS 版本 5.1 没有 Remove-Service 命令
    # This cmdlet was added in PS v6. See https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-core-60?view=powershell-6#cmdlet-updates.
    #Remove-Service -Name "gupdate"
    #Remove-Service -Name "gupdatem"
    #Remove-Service -Name "GoogleChromeElevationService"
    # sc 在 PowerShell 中是 Set-Content 别名，所以要使用 sc.exe 否则执行后无任何效果
    sc.exe delete "gupdate"
    sc.exe delete "gupdatem"
    sc.exe delete "GoogleChromeElevationService"
    # 任务计划企业版
    schtasks.exe /Delete /TN \GoogleUpdateBrowserReplacementTask /F
    schtasks.exe /Delete /TN \GoogleUpdateTaskMachineCore /F
    schtasks.exe /Delete /TN \GoogleUpdateTaskMachineUA /F
    # 移除更新程序
    Remove-Item "$PF\Google\Update\" -Recurse  -Force
    echo "Disable Google Chrome Enterprise x64 Auto Update Successful!"
}
elseif ($(Test-Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe") -eq "true") {
    # 结束进程
    taskkill /im chrome.exe /f
    taskkill /im GoogleUpdate.exe /f
    # Google Chrome 更新服务
    #这里也可以使用 sc.exe stop "service name"
    Stop-Service -Name "gupdate"
    Stop-Service -Name "gupdatem"
    Stop-Service -Name "GoogleChromeElevationService"
    # Windows 10 默认 PS 版本 5.1 没有 Remove-Service 命令
    # This cmdlet was added in PS v6. See https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-core-60?view=powershell-6#cmdlet-updates.
    #Remove-Service -Name "gupdate"
    #Remove-Service -Name "gupdatem"
    #Remove-Service -Name "GoogleChromeElevationService"
    # sc 在 PowerShell 中是 Set-Content 别名，所以要使用 sc.exe 否则执行后无任何效果
    sc.exe delete "gupdate"
    sc.exe delete "gupdatem"
    sc.exe delete "GoogleChromeElevationService"
    # 任务计划企业版
    schtasks.exe /Delete /TN \GoogleUpdateBrowserReplacementTask /F
    schtasks.exe /Delete /TN \GoogleUpdateTaskMachineCore /F
    schtasks.exe /Delete /TN \GoogleUpdateTaskMachineUA /F
    # 移除更新程序
    Remove-Item "$PF\Google\Update\" -Recurse  -Force
    echo "Disable Google Chrome Enterprise x86 Auto Update Successful!"
}
else {
    echo "No Google Chrome Enterprise Installation Detected!"
}