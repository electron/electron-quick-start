#Requires -RunAsAdministrator


#---------------------------------------------------------[Parameters]--------------------------------------------------------
#region parameters
param(
    [parameter(Mandatory = $true)] [string]$JSON,
    [string]$logfile
)

#endregion

#----------------------------------------------------------[Initializations]----------------------------------------------------------
#region initializations

#script variables
$config = @{ }

#set location to script location
push-location $PSScriptRoot

#set the window title
$Host.UI.RawUI.WindowTitle = "Save User Profile"

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

function scanState($config) {
    #move to script location
    Push-Location $config.extractFolder

    #extract folders
    .\7za.exe x usmt.7z -aoa
    .\7za.exe x usmt-config.7z -aoa

    if($config.username -and $config.plaintextpassword) {
        $config.saveloc = $config.NetworkDrive

        #generate credential
        $password = ConvertTo-SecureString $config.plaintextpassword -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($config.username, $password)

        #map drive if needed
        try {
            $drive = New-PSDrive -root $config.saveloc -PSProvider "filesystem" -name "backupLoc" -Credential $cred -scope global
        } catch {
            write-error "could not mount root drive, removing target folder and exiting"
            remove-item -path $config.extractFolder -Recurse
            exit 1
        }
    } else {
        $config.saveloc = $config.LocalDrive
    }

    $config.saveloc += "\" + $config.backupName

    if(!(test-path $config.saveloc)) {
        new-item -path $config.saveloc -force -confirm:$false -itemtype Directory -ErrorAction Stop
    }

    # generate command line
    $argList = @("$($config.saveloc)", "/localonly", "/efs:skip", "/vsc", "/c", "/o", "/ue:*\*")

    foreach ($user in $config.users) {
        $arglist += ("/ui:" + $user)
        write-output "adding user $user"
    }

    $arglist += @("/i:$pwd\migapp.xml", "/i:$pwd\migdocs.xml", "/i:$pwd\inclusions.xml", "/i:$pwd\exclusions.xml")
    write-output "final command:`n$pwd\scanstate.exe $argList"
    write-output "starting in 5 seconds"
    start-sleep 5
    &".\scanstate.exe" $argList

    pop-location
    push-location C:\
    write-output "completed, removing working directory $($config.extractFolder)"
    remove-item -path $config.extractFolder -Recurse
    if($config.username -and $config.plaintextpassword) {
        remove-psdrive $drive
    }
}

#endregion

#----------------------------------------------------------[Main Script]----------------------------------------------------------
#region Main Script

#generate remote session if required
if (!($config.LocalHost)) {
    try {
        $session = new-pssession -ComputerName $config.computername -ErrorAction Stop
    }
    catch {
        write-error "could not generate a session on $($config.computername), are you sure you have access? try manually with enter-pssession"
        exit 1
    }
    $destination = invoke-command -session $session -scriptblock { write-output "$env:localappdata\cb\backup-userprofiles" }
}
else {
    $destination = "$env:localappdata\cb\backup-userprofiles"
    $session = $null
}

$config.extractFolder = $destination
write-output "working folder: $destination"

if($session) {
    write-output "copying setup files."
    $scriptblock = [scriptblock]::Create("new-item '$destination' -type directory -force")
    invoke-command -session $session -scriptblock $scriptblock
    copy-item -path "$pwd\tools\7z*" -Destination $destination -Force -ToSession $session

    if([Environment]::Is64BitOperatingSystem) {
        copy-item -path "$pwd\files\usmt-64.7z" -Destination "$destination\usmt.7z" -Force -ToSession $session
    } else {
        copy-item -path "$pwd\files\usmt-32.7z" -Destination "$destination\usmt.7z" -Force -ToSession $session
    }
    copy-item -path "$pwd\files\usmt-config.7z" -Destination "$destination\usmt-config.7z" -Force -ToSession $session

    invoke-command -session $session -scriptblock ${function:scanState} -ArgumentList $config

    remove-pssession $session

} else {
    write-output "copying setup files."
    new-item $destination -type directory -force
    copy-item -path "$pwd\tools\7z*" -Destination $destination -Force

    if([Environment]::Is64BitOperatingSystem) {
        copy-item -path "$pwd\files\usmt-64.7z" -Destination "$destination\usmt.7z" -Force
    } else {
        copy-item -path "$pwd\files\usmt-32.7z" -Destination "$destination\usmt.7z" -Force
    }
    copy-item -path "$pwd\files\usmt-config.7z" -Destination "$destination\usmt-config.7z" -Force
    scanState $config
}

#endregion