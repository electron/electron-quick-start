#turn off hibernate
&powercfg -h off
#set power plan to "high performance"
&powercfg setactive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

#enable admin shares
Set-NetFirewallRule -Name 'FPS-SMB-In-TCP-NoScope' -Enabled True
Set-NetFirewallRule -Name 'FPS-SMB-Out-TCP-NoScope' -Enabled True

#enable icmp
netsh advfirewall firewall add rule name="ping" protocol=ICMPV4 dir=in action=allow

#Enable remote administration
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

#enable powershell remoting
enable-psremoting -force -skipnetworkprofilecheck

#set execution policy
Set-ExecutionPolicy RemoteSigned -confirm:$false

#install chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install wifi
if($config.flags.wifi) {
	foreach ($wifi in (Get-ChildItem "C:\temp\deploy\wifi\*.xml")) {
		&netsh wlan add profile filename="$($wifi.fullName)" user=all
	}
}

#install third party programs
Set-Location "C:\temp\deploy\installers"
foreach ($directory in (Get-ChildItem ".\*" -Directory)) {
	Push-Location $directory
	.\install.ps1 | out-host
	Pop-Location
}

#remove yourself
start-sleep -s 5
set-location C:\
Remove-Item -Recurse -Force C:\temp