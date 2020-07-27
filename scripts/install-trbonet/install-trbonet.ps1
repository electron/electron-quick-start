#---------------------------------------------------------[Parameters]--------------------------------------------------------
#region parameters
[cmdletbinding(defaultparametersetname = 'cmd')]
param(
    [parameter(ParameterSetName = 'cmd')] [string]$ComputerName,
    [parameter(ParameterSetName = 'cmd')] [PSCredential] $Credential,
    [parameter(ParameterSetName = 'cmd')] [string]$trbonetPath,
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
$Host.UI.RawUI.WindowTitle = "Install-TRBOnet"

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
}
catch {
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

#-----------------------------------------------------[Validation Checks]--------------------------------------------------------
#region validationchecks

#endregion

#----------------------------------------------------[Functions]-------------------------------------------------------------------
#region functions
function installTrbonet($JSON) {
    $config = convertfrom-json ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($JSON)))
    
    #generate credential
    $password = ConvertTo-SecureString $config.plaintextpassword -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($config.username, $password)

    #mount shared folder
    $trboNetFolder = split-path $config.trbonetPath
    write-output "mounting $trboNetFolder"
    try {
        New-PSDrive -Name "trbonet" -Root $trboNetFolder -PSProvider "FileSystem" -Credential $cred -ErrorAction stop
    }
    catch {
        write-error "could not mount network share, exiting"
        exit 1
    }

    write-output "Killing any open instances of trbonet..."

    Get-Process "trbo*" | Stop-Process -force -confirm:$false

    write-output "backing up any existing trbonet configs"
    foreach ($user in ((Get-ChildItem "C:\users\*").basename)) {
        $path = "C:\users\$user\appdata\roaming\Neocom Software"
        if (test-path $path) {
            move-item $path $path.bak -force -confirm:$false
        }
    }

    write-output "Uninstalling all previous TRBOnets"
    wmic product where "name like 'TRBOnet%'" call uninstall

    write-output "Installing TRBOnet Plus"
    &$config.trbonetPath /qn
    write-output "waiting for install to finish"
    do {
        start-sleep 5
    } while (get-process | select-string "TRBO")

    write-output "moving configs back"
    foreach ($user in ((Get-ChildItem "C:\users\*").basename)) {
        $path = "C:\users\$user\appdata\roaming\Neocom Software"
        if (test-path "$path.bak") {
            move-item "$path.bak" $path -force -confirm:$false
        }
    }

    write-output "finished!"
}

#endregion

#----------------------------------------------------[Execution]-------------------------------------------------------------------

try {
    $session = new-pssession -ComputerName $config.computername -erroraction stop
}
catch {
    write-error "could not generate a session on $($config.computername), are you sure you have access? try manually with enter-pssession"
    exit 1
}

$base64Config = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((convertto-json $config)))
invoke-command -session $session -scriptblock ${function:installTrbonet} -ArgumentList @($base64Config)

Remove-PSSession -session $session