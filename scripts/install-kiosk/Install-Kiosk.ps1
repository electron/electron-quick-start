<#

#>

#---------------------------------------------------------[Parameters]--------------------------------------------------------
#region parameters
[cmdletbinding(defaultparametersetname = 'cmd')]
param(
    [parameter(ParameterSetName = 'cmd')] [string]$ComputerName,
    [parameter(ParameterSetName = 'cmd')] [PSCredential] $Credential,
    [parameter(ParameterSetName = 'cmd')] [securestring]$KioskPassword,
    [parameter(ParameterSetName = 'cmd')] [switch]$BackgroundImage,
    [parameter(ParameterSetName = 'cmd')] [switch]$EnableRDP,
    [parameter(ParameterSetName = 'cmd')] [string]$RDPURL,
    [parameter(ParameterSetName = 'cmd')] [string]$RDPDomain,
    [parameter(ParameterSetName = 'cmd')] [string]$RDPUserName,
    [parameter(ParameterSetName = 'cmd')] [securestring]$RDPPassword,
    [parameter(ParameterSetName = 'cmd')] [string]$RDPResolution,
    [parameter(ParameterSetName = 'cmd')] [switch]$EnableBrowser,
    [parameter(ParameterSetName = 'cmd')] [switch]$AutoHideCursor,
    [parameter(ParameterSetName = 'cmd')] [switch]$BrowserKioskMode,
    [parameter(ParameterSetName = 'cmd')] [switch]$BrowserAutoRefresh,
    [parameter(ParameterSetName = 'cmd')] [string]$BrowserURL,
    [parameter(ParameterSetName = 'cmd')] [string[]]$BrowserURLWhitelist,
    [parameter(ParameterSetName = 'cmd')] [switch]$EnableXibo,
    [parameter(ParameterSetName = 'cmd')] [switch]$EnableMeshCentral,
    [parameter(ParameterSetName = 'cmd')] [string]$MeshCentralURL,
    [parameter(ParameterSetName = 'cmd')] [string]$MeshCentralGroupKey,
    [parameter(ParameterSetName = 'cmd')] [switch]$MeshCentralForceReinstall,
    [parameter(ParameterSetName = 'cmd')] [string]$customStartup,
    [parameter(ParameterSetName = 'json', Mandatory = $true)] [string]$JSON,
    [string]$Logfile
)

#endregion

#----------------------------------------------------------[Initializations]----------------------------------------------------------
#region initializations

#set location to script location
push-location $PSScriptRoot

#our main config variable
$config = @{ }

#set the window title
$Host.UI.RawUI.WindowTitle = "Install-Kiosk"

# this section determines if we have used a JSON or not. If we have, we are just going to convert the JSON file.
# Otherwise, we will create a hashtable with all the same arguments as the JSON file would have had.
$parameterlist = $MyInvocation.mycommand.Parameters
foreach ($key in $ParameterList.keys) {
    $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
    #add to config variable
    if ($var.value) {
        $config.($var.name) = $var.value
    }
}

if ($JSON) {
    #we do not know if we've been provided a path to a config file or a direct JSON string, so we try both
    try {
        $parsedJSON = ConvertFrom-Json (get-content -raw -path $JSON -ErrorAction Stop)
    }
    catch {
        try {
            $parsedJSON = ConvertFrom-Json $JSON
        }
        catch {
            throw "the JSON given doesn't appear to be valid, please provide either the path to the config file or the raw JSON as a string"
        }
    }
    #convert JSON from pscustomobject to hashtable so we can modify it freely
    $parsedJSON.psobject.properties | ForEach-Object { $config[$_.Name] = $_.Value }
}

#convert all switches to booleans. We do this because passing switches as JSON doesn't behave as expected
try {
    $keys = ($config.keys).clone()
} catch {
    $keys = $null
}
foreach ($key in $keys) {
    if ($config[$key]) {
        if ($config[$key].gettype().name -eq "SwitchParameter") {
            $config[$key] = $config[$key].IsPresent
        }
    }
}
$keys = $null
#set Debug
if ($Verbose) {
    Set-PSDebug -Trace 2
}
else {
    set-psdebug -trace 0
}

#set logging
if ($config.LogFile) {
    start-transcript -path $config.LogFile
}

#endregion

#----------------------------------------------------------[region Local Variables]----------------------------------------------------------
#region local variables

$localFolder = "$pwd\files"
$psftpLoc = "$pwd\tools\psftp.exe"
$psftpDownloadLoc = "https://the.earth.li/~sgtatham/putty/latest/w64/psftp.exe"
$plinkLoc = "$pwd\tools\plink.exe"
$plinkDownloadLoc = "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe"

#endregion

#----------------------------------------------------------[Imports]----------------------------------------------------------
#region Imports

if (!(test-path "$pwd\tools")) {
    new-item -ItemType Directory -path "$pwd\tools"
}

write-host "Checking for existence of plink."
if (!(test-path $plinkLoc)) {
    try {
        write-host "did not find plink at `"$plinkLoc`", downloading from the web"
        Invoke-WebRequest $plinkDownloadLoc -OutFile $plinkLoc
        write-host "finished downloading plink"
    }
    catch {
        throw "did not manage to download plink.exe"
    }
}
else {
    write-host "plink found at `"$plinkLoc`""
}


write-host "Checking for existence of psftp."
if (!(test-path $psftpLoc)) {
    try {
        write-host "did not find psftp at `"$psftpLoc`", downloading from the web"
        Invoke-WebRequest $psftpDownloadLoc -OutFile $psftpLoc
        write-host "finished downloading psftp"
    }
    catch {
        throw "did not manage to download psftp.exe"
    }
}
else {
    write-host "psftp found at `"$psftpLoc`""
}

#endregion

#-----------------------------------------------------[Validation Checks]--------------------------------------------------------
#region validationchecks


# Note: we need all passwords in plaintext because there is no secure method of password transmission to linux via powershell. Note that
# this is *sort* of OK because we are transferring the parameters via SSH which is an encrypted tunnel. Not ideal, but secure enough.

if (!($config.username)) {
    $config.UserName = [PSCredential]::new($config.Credential).GetNetworkCredential().UserName
}

if (!($config.plaintextpassword)) {
    $config.PlainTextPassword = [PSCredential]::new($config.Credential).GetNetworkCredential().Password
}

if (!$config.plaintextkioskpassword) {
    $config.plaintextkioskpassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.KioskPassword))
}

if (!$config.plaintextrdppassword -and $config.rdpenabled) {
    $config.plaintextrdppassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.RDPPassword))
}

#endregion


#----------------------------------------------------[Execution]-------------------------------------------------------------------
#remove any secure strings, because we can't transfer them as JSON
$config.remove("credential")
$config.remove("RootPassword")
$config.remove("KioskPassword")
$config.remove("RDPPassword")
$config.remove("json")

if($config.enableXibo) {
    $config.extrainitcommands = "bash -c 'xibo-player'; exit"
}

#converting line endings to linux before transferring
write-host "converting all files to linux line endings"
foreach ($file in (Get-ChildItem $localFolder -Recurse -File)) {
    (Get-Content $file.fullname -Raw).Replace("`r`n", "`n") | Set-Content $file.fullname -Force -NoNewline
}

#auto-accepting the cache key if it hasn't already
write-host "testing the connection to the server"
"yes" | &$psftploc -pw "$($config.plaintextpassword)" "$($config.username)@$($config.computername)" | write-verbose
if ($LASTEXITCODE -ne 0) {
    throw "could not connect to remote machine, maybe invalid ssh key cached, password or computer name?
    (clear cache with remove-item -path HKCU:\Software\SimonTatham\PuTTY\SshHostKeys)"
}

#get the architecture to determine what device we are installing on
$plinkArgs = @("-batch", "-ssh", "-pw", $config.plaintextpassword, "$($config.username)@$($config.ComputerName)", "cat /etc/os-release")

#this parses the text to get the architecture
$config.architecture = (&"$plinkloc" $plinkArgs | select-string -pattern "^ID=(.*)").matches.groups[1].value
write-output $arch

if($config.architecture -eq "ubuntu") {
    write-output "Detected destination kiosk as a ubuntu kiosk"
} elseif ($config.architecture -eq "raspbian") {
    write-output "detected destination kiosk as a raspberry pi"
    if($config.enableXibo) {
        throw "Detected a raspberry pi, but cannot install Xibo to a pi. Exiting"
    }
} else {
    throw "cannot determine architecture, exiting"
}

#Moving all files across to the remote machine
write-host "using sftp to move all files to remote server"
"put -r `"$pwd\files`" /tmp/files" | &$psftpLoc -batch -pw "$($config.plaintextpassword)" "$($config.username)@$($config.computername)" | Write-Verbose

if($config.username -ne "root") {
    write-host "Enabling root if not done so"
    $plinkArgs = @("-batch", "-ssh", "-pw", $config.plaintextpassword, "$($config.username)@$($config.ComputerName)", "chmod +x /tmp/files/Enable-Root.sh && echo `"$($config.plaintextpassword)`" | sudo -S /tmp/files/Enable-Root.sh $($config.plaintextkioskpassword)")
    &"$plinkloc" $plinkArgs
    $config.plaintextpassword = $config.plaintextkioskpassword
}

#install powershell on the remote host
write-host "testing and installing powershell if not present"
$plinkArgs = @("-batch", "-ssh", "-pw", $config.plaintextpassword, "root@$($config.ComputerName)", "chmod +x /tmp/files/Install-Powershell.sh && /tmp/files/Install-Powershell.sh")
&"$plinkloc" $plinkArgs

#next step is to run the rest of the script in powershell mode. We pass all arguments as a base64 encoded JSON to avoid string parsing issues
write-host "performing configuration tasks"
$base64Config = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((convertto-json $config)))
$plinkArgs = @("-batch", "-ssh", "-pw", $config.plaintextpassword, "root@$($config.ComputerName)", "pwsh /tmp/files/Set-KioskConfig.ps1 -json `'$base64Config`'")
&"$plinkloc" $plinkArgs


try {
    stop-transcript | out-null
}
catch [System.InvalidOperationException] { }

set-psdebug -trace 0