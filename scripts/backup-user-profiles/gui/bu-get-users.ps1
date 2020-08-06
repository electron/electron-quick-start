#Requires -RunAsAdministrator


#---------------------------------------------------------[Parameters]--------------------------------------------------------
#region parameters

[cmdletbinding(defaultparametersetname = 'cmd')]
param(
    [parameter(ParameterSetName = 'cmd')] [string]$ComputerName,
    [parameter(ParameterSetName = 'cmd')] [boolean]$LocalHost,
    [parameter(ParameterSetName = 'json', Mandatory = $true)] [string]$JSON,
    [string]$logfile
)

#endregion

#----------------------------------------------------------[Initializations]----------------------------------------------------------
#region initializations

#script variables
$config = @{ }

#set location to script location
push-location $PSScriptRoot

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
$keys = $config.keys
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

#----------------------------------------------------------[Functions]----------------------------------------------------------
#region Functions
function getUsers() {
    $path = 'Registry::HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*'
    $items = Get-ItemProperty -path $path
    Foreach ($item in $items) {
        $objUser = New-Object System.Security.Principal.SecurityIdentifier($item.PSChildName)
        #we want to ignore errors here, so we don't catch
        try {
            $objName = $objUser.Translate([System.Security.Principal.NTAccount])
        } catch {}
        $item.PSChildName = $objName.value
    }
    $items = $items | Where-Object {$_.pschildname -notlike "NT AUTHORITY*"}

    #rename relevant properties
    $returnVal = @{}
    $returnVal.name = @()
    $returnVal.description = @()

    foreach ($item in $items) {
        $returnVal.name += $item.pschildname
        $returnVal.description += "$($item.profileimagepath)    ($($item.pschildname))"
    }
    return $returnVal
}

#endregion

#----------------------------------------------------------[Main Script]----------------------------------------------------------
#region Main Script

#generate remote session if required
if (!$config.LocalHost) {
    try {
        $session = new-pssession -ComputerName $config.computername -ErrorAction Stop
    }
    catch {
        write-error "could not generate a session on $($config.computername), are you sure you have access? try manually with enter-pssession"
        exit 1
    }
}

if($session) {
    #get the users
    $userlist = (invoke-command -session $session -scriptblock ${function:getUsers})
    remove-pssession $session
} else {
    $userlist = getUsers
}

return ConvertTo-Json $userlist

#endregion