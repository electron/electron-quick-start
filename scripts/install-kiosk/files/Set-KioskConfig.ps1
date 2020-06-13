<#
.SYNOPSIS
    This is the remote side of the Set-KioskConfig script. Please see the original script for documentation
.PARAMETER JSON
    A predefined config file with the parameters defined in Set-KioskConfig.ps1.
.EXAMPLE
    Set-KioskConfig -JSON <JSON string>

#>

#---------------------------------------------------------[Parameters]--------------------------------------------------------

param([string]$JSON)

#---------------------------------------------------------[Initialisations]-----------------------------------------------------

#Convert JSON into our config object
$config = convertfrom-json $JSON

if (!$config) {
    write-error "JSON parsing went wrong"
    exit
}

#set location to script location
push-location "/tmp/"

#----------------------------------------------------------[Imports]----------------------------------------------------------

import-module "/tmp/files/Modules/Get-VariableValues.psm1"

#------------------------------------------------------[Local Variables]--------------------------------------------------------

$installList = @("feh", "i3", "tmux", "xdotool", "unclutter", "cockpit", "cockpit-packagekit")

#Set-PSDebug -trace 0

#-------------------------------------------------------------[Execution]-------------------------------------------------------
$env:DEBIAN_FRONTEND = "noninteractive"
"APT::Acquire::Retries `"3`";" | Out-File /etc/apt/apt.conf.d/80-retries

#disable ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1

write-output "updating system"
apt-get update
apt-get dist-upgrade -qy

write-output "installing applications for kiosk"

if($config.enableRDP) {
    $installList += "freerdp2-x11"
}
if($config.enableXibo) {
    snap install xibo-player
}
if($config.EnableBrowser) {
    if($config.architecture -eq "ubuntu") {
        $installList += "chromium-browser"
    }
}

apt-get install $installList -qy -o Dpkg::Options::=`"--force-confnew`"

#delete all users with of 1000 or over
write-host "removing any previously configured users (including installation user)..."
$users = get-content "/etc/passwd" | select-string -pattern ":1[0-9][0-9][0-9]"

foreach ($user in $users) {
    $userName = ($user -split ":")[0]
    userdel -f $username --remove
}

write-host "creating user kiosk..."
#create user
adduser --disabled-login --gecos " " "kiosk"
usermod -a -G "video" "kiosk"
"kiosk:$($config.PlainTextKioskPassword)" | chpasswd


#set autologin
if($config.architecture -eq "raspbian") {
    $lightdm = (get-content "/etc/lightdm/lightdm.conf")
    $lightdm = $lightdm.replace("#autologin-session=","autologin-session=i3")
    $lightdm = $lightdm -replace "autologin-user=.*","autologin-user=kiosk"
    $lightdm | set-content /etc/lightdm/lightdm.conf
} else {
    get-content "$pwd/files/var/lib/AccountsService/users/kiosk" | set-content "/var/lib/AccountsService/users/kiosk"
    (get-content "/etc/gdm3/custom.conf") -replace "AutomaticLogin=.*","AutomaticLogin=kiosk" | set-content "/etc/gdm3/custom.conf"
}

#move both user login scripts into place
write-output "placing user files"
copy-item "$pwd/files/home/kiosk/*" "/home/kiosk" -recurse -Force
chmod +x "/home/kiosk/autorefresh.sh"

$startup = Get-VariableValues -content (get-content "/home/kiosk/startup.sh" -raw) -config $config
if ($config.AutoHideCursor) {
    $startup = $startup.replace("#unclutter", "unclutter")
}

if ($config.EnableRDP) {
    $startup = $startup.replace("#xfreerdp", "xfreerdp")
}

if ($config.EnableBrowser) {
    $startup = $startup.replace("#sed", "sed")
    $startup = $startup.replace("#chromium-browser", "chromium-browser")
}

if ($config.BackgroundImage) {
    $startup = $startup.replace("#feh", "feh")
}

if ($config.RDPResolution) {
    $startup = $startup.replace("/gdi:hw", "/gdi:hw /smart-sizing:$($config.RDPResolution)")
}

if (!($config.BrowserKioskMode)) {
    $startup = $startup.replace("--kiosk ", "")
    $startup = $startup.replace("--start-fullscreen ", "")
    $startup = $startup.replace("--app=", "")
}

$chromeConfig = @{}
$parsedJSON = ConvertFrom-Json (get-content "$pwd/files/etc/chromium-browser/policies/managed/default_policy.json" -raw)
$parsedJSON.psobject.properties | ForEach-Object { $chromeConfig[$_.Name] = $_.Value }
$chromeConfig.HomepageLocation = $config.BrowserURL

if ($config.BrowserURLWhitelist) {
    $chromeConfig.URLWhitelist = $config.BrowserURLWhitelist
    $chromeConfig.URLBlacklist = @(,"*")
    $chromeConfig.ExtensionInstallForceList = $config.BrowserExtensionInstallForceList
}

if (!(test-path "/etc/chromium-browser/policies/managed")) {
    new-item -itemtype directory -force "/etc/chromium-browser/policies/managed"
}
ConvertTo-Json $chromeConfig | out-file "/etc/chromium-browser/policies/managed/default_policy.json"

if ($config.KioskResolution) {
    $startup = $startup.replace('#xrandr', "xrandr")
}

if ($config.browserAutoRefresh) {
    $startup = $startup.replace('#/home/', "/home/")
}

$startup | set-content "/home/kiosk/startup.sh"
chmod +x "/home/kiosk/startup.sh"

#change ownership of all the files within home to the home user
chown -R "1000:1000" "/home/kiosk"

#enable meshcentral remote desktop if required
if ($config.enableMeshCentral) {
    if ((!(systemctl | select-string meshagent)) -or $config.meshcentralforcereinstall) {
        write-output "enabling (or reinstalling) meshcentral..."
        wget "$($config.MeshCentralURL)/meshagents?script=1" --no-check-certificate -O ./meshinstall.sh
        chmod 755 ./meshinstall.sh
        bash ./meshinstall.sh "$($config.MeshCentralURL)" $config.MeshCentralGroupKey

        #add a delay to meshagent on boot so it detects the X session
        if (!(test-path "/etc/systemd/system/meshagent.service.d")) {
            new-item -ItemType directory -path "/etc/systemd/system/meshagent.service.d"
        }
        "[Service]`nExecStartPre=/bin/sleep 30" | out-file "/etc/systemd/system/meshagent.service.d/override.conf"
    }
    else {
        write-output "Meshagent already detected, moving on..."
    }
}

#remove history
bash -c "set -x && cat /dev/null > /root/.bash_history && history -c && exit"

# Reboot on finish
write-output "rebooting in 30 seconds"
#put in a one minute delay to allow things like meshcentral to finish initializing
start-sleep 29
write-output 'finished script'
start-sleep 1
reboot now
