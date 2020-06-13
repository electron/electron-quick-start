#Requires -RunAsAdministrator

<#
.SYNOPSIS
    This script will customize and install windows from a PE environment
.PARAMETER ImageLocation
    location of the .wim or .swm file storing the images.
.PARAMETER ImageIndex
    Index of the image file we are installing.
.PARAMETER DiskNumber
    The index of the disk we are installing to (usually 0). CHOOSE CAREFULLY. This will determine which drive gets erased!
.PARAMETER Profile
    The profile of customizations, found within Install-Windows\files. "Default" profile chosen by default. Additional profiles can be created by copying the folder structure to a new profile name in this same area
.PARAMETER ComputerName
    The new name of the computer we are installing.
.PARAMETER UEFIMode
    (Optional, Switch) enabling this switch will install windows in UEFI mode.
.PARAMETER EnableJoinDomain
    (Optional, Switch) enables the ability to join the domain, defaults to workgroup.
.PARAMETER JoinDomainCredential
    (If JoinDomain is enabled) The FQDN (domain\user, password) of the user with authority to join the domain as a PScredential. Will prompt if not provided
.PARAMETER Installers
    (Optional) An array of what software to install.
.PARAMETER DriverFolder
    (Optional) a path to a folder containing drivers you want to integrate
.PARAMETER JSON
    (Optional) A predefined config file with the above parameters.
.PARAMETER LogFile
    (Optional) Location of log output. Disabled by default.
.EXAMPLE
    Install-Windows
.EXAMPLE
    Install-Kiosk -JSON <JSON string>

#>

#---------------------------------------------------------[Parameters]--------------------------------------------------------
#region parameters
[cmdletbinding(defaultparametersetname = 'cmd')]
param(
    [parameter(ParameterSetName = 'cmd')] [string]$ImageLocation,
    [parameter(ParameterSetName = 'cmd')] [int]$ImageIndex,
    [parameter(ParameterSetName = 'cmd')] [int]$DiskNumber,
    [parameter(ParameterSetName = 'cmd')] [string]$Profile,
    [parameter(ParameterSetName = 'cmd')] [string]$ComputerName,
    [parameter(ParameterSetName = 'cmd')] [switch]$UEFIMode,
    [parameter(ParameterSetName = 'cmd')] [switch]$EnableJoinDomain,
    [parameter(ParameterSetName = 'cmd')] [pscredential]$JoinDomainCredential,
    [parameter(ParameterSetName = 'cmd')] [string[]]$Installers,
    [parameter(ParameterSetName = 'cmd')] [string]$DriverFolder,
    [parameter(ParameterSetName = 'cmd')] [switch]$Wifi,
    [parameter(ParameterSetName = 'json')][string]$JSON,
    [string]$logFile
)

#endregion

#----------------------------------------------------------[Initializations]----------------------------------------------------------
#region initializations

#set location to script location
push-location $PSScriptRoot

#dependencies
import-module ..\_modules\dism\dism.psd1

#our main config variable
$config = @{ }

#set the window title
$Host.UI.RawUI.WindowTitle = "Install-Windows"

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
            write-error "the JSON given doesn't appear to be valid, please provide either the path to the config file or the raw JSON as a string"
            exit 1
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

#----------------------------------------------------------[Local Variables]----------------------------------------------------------
#region local variables
#endregion

#----------------------------------------------------------[Imports]----------------------------------------------------------
#region Imports
#endregion

#----------------------------------------------------------[Validation]----------------------------------------------------------
#region Validation

if($env:systemdrive -ne "X:") {
    write-error "This is not a PE environment, stopping now"
    exit 1
}

if ($config.EnableJoinDomain) {
    #check to see if we have preapplied variables first
    if (!($config.plaintextpassword -and $config.username -and $config.domain)) {
        $config.username = ($config.joindomainCredential).GetNetworkCredential().UserName
        $config.domain = ($config.joindomainCredential).GetNetworkCredential().domain
        $config.plaintextpassword = ($config.joindomainCredential).GetNetworkCredential().password
    }

    #test the credentials against the domain
    write-output "testing credentials (note: this only checks if your credentials are valid, not if they have rights to join computers to the domain)"
    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ContextType, $config.domain
    $ValidAccount = $PrincipalContext.ValidateCredentials($config.username, $config.plaintextpassword)
    if (!($ValidAccount)) {
        write-error "credentials did not work, please try re-entering"
        exit 1
    } else {
        write-output "Credentials accepted!"
    }
}

#endregion
#-----------------------------------------------------[Confirmation]--------------------------------------------------------

#-----------------------------------------------------[Execution]--------------------------------------------------------

#Formatting Drive
write-host "(1/3) - formatting disk"

if ($config.UEFIMode) {
    $diskPartCommands = @(
        "select disk $($config.diskNumber)"
        "clean"
        "convert gpt"
        "create partition efi size=300"
        "format quick fs=fat32 label=`"System`""
        "assign letter=`"N`""
        "create partition msr size=128"
        "create partition primary"
        "format quick fs=ntfs label=`"Windows`""
        "assign letter=`"O`""
        "exit"
    )
    $diskPartCommands | diskpart.exe | write-output
}
else {
    $diskPartCommands = @(
        "select disk $($config.diskNumber)"
        "clean"
        "create partition primary size=100"
        "format quick fs=ntfs label=`"System`""
        "assign letter=`"N`""
        "active"
        "create partition primary"
        "format quick fs=ntfs label=`"Windows`""
        "assign letter=`"O`""
        "exit"
    )
    $diskPartCommands | diskpart.exe | write-output
}

#Applying the windows image
write-host "(2/3) - Applying windows image"

if (($config.imagelocation.split("."))[-1] -eq "swm") {
    #parse the image location to add a wildcard for the image file pattern
    $path = (($config.imagelocation).substring(0, ($config.imagelocation).lastIndexOf('.'))) + "*." + ($config.imagelocation.split("."))[-1]

    Expand-WindowsImage -imagepath $config.imagelocation -index $config.imageindex  -applypath "O:\" -SplitImageFilePattern $path
}
else {
    Expand-WindowsImage -imagepath $config.imagelocation -index $config.imageindex -applypath "O:\"
}

#Applying the system partition
&bcdboot O:\windows /s N: /f all | write-output

#add "everyone" permissions to windows/temp folder to avoid MSI bug in windows
&icacls "O:\Windows\temp" /setowner "Everyone" /T /C
&icacls "O:\Windows\temp" /t /grant Everyone:F

#customizations
write-host "(3/3) - applying unattend settings"

#import the template XML
if ($config.EnableJoinDomain) {
    $xml = get-content "$pwd\files\$($config.profile)\unattendxml\domain.xml"
}
else {
    $xml = get-content "$pwd\files\$($config.profile)\unattendxml\workgroup.xml"
}

#this tricky code essentially replaces all raw $($keyname) in a string with the matching value out of $config
#so you have a raw string like '$($stuff) and $($things)' and $config.stuff has "hello" and $config.things has "world"
#running the below would change the raw string to 'hello and world'. This allows for mass replacements in a file where we have placeholders
$replacementVars = ($xml | select-string '\$\(\$(.*?)\)' -allmatches | ForEach-Object matches | ForEach-Object groups | ForEach-Object value)
for ($i = 1; $i -lt $replacementVars.length; $i += 2) {
    $xml = $xml.replace($replacementVars[$i - 1], $config[$replacementVars[$i]])
}

#save the data
New-Item -ItemType Directory -Path "O:\windows\panther"
$xml | Out-File "O:\windows\panther\unattend.xml"

#copy across the first run script
New-Item -ItemType Directory -Path "O:\temp"
Copy-Item "$pwd\files\$($config.profile)\post-boot\firstrun.ps1" "O:\temp\firstrun.ps1"

#install updates
if (test-path "$pwd\files\$($config.profile)\updates\*.msu") {
    if (Get-ChildItem "$pwd\files\$($config.profile)\updates\*.msu") {
        Add-WindowsPackage -packagepath "$pwd\files\$($config.profile)\updates" -path "O:\"
    }   
}

#install drivers
if ($config.DriverFolder) {
    add-windowsdriver -recurse -path "O:\" -driver $config.DriverFolder -Verbose
}

#if we are also copying the installers, do that now
New-Item -ItemType Directory -Path "O:\temp\deploy\installers" -Force
foreach ($installer in $config.installers) {
    write-output $installer
    copy-item "$pwd\..\assets\installers\$installer" "O:\temp\deploy\installers\$installer" -recurse
}

#wifi profiles
if ($config.wifi) {
    copy-item "$pwd\files\$($config.profile)\wifi" "O:\temp\deploy\wifi" -recurse
}


#apply start menu layout
if (-not (test-path "O:\Users\Default\AppData\Local\Microsoft\Windows\Shell")) {
    New-Item -ItemType Directory -Path "O:\Users\Default\AppData\Local\Microsoft\Windows\Shell" -Force
}
Copy-Item -Path "$pwd\files\$($config.profile)\StartLayoutXML\LayoutModification.xml" -Destination "O:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"

#apply registry tweaks
#mount the offline hive
write-output "mounting system registry"
&reg load HKLM\wimregistrysystem "O:\windows\system32\config\system"
write-output "mounting software registry"
&reg load HKLM\wimregistrysoftware "O:\windows\system32\config\software"
write-output "mounting default user registry"
&reg load HKLM\wimregistryuser "O:\Users\Default\NTUSER.DAT"

#now we iterate through every reg entry and add it to the offline hive
write-output "loading reg files"
Get-ChildItem ("$pwd\files\$($config.profile)\regedits\*.reg") | foreach-object {
    #create a temporary reg file
    $currentReg = "$env:temp\currentReg.reg"
    #change the names to point to the loaded hives
    write-output "reg file $($_.fullname)"
    (get-content $_.fullname).replace("HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE\wimregistryuser").replace("HKEY_LOCAL_MACHINE\SOFTWARE", "HKEY_LOCAL_MACHINE\wimregistrysoftware").replace("HKEY_LOCAL_MACHINE\SYSTEM", "HKEY_LOCAL_MACHINE\wimregistrysystem") | out-file $currentReg
    #import the registry file
    &reg import $currentReg
    #remove the temporary hive file
    remove-item $currentReg
}

#unmount the offline hives
write-output "unmounting system registry"
&reg unload HKLM\wimregistrysystem
write-output "unmounting software registry"
&reg unload HKLM\wimregistrysoftware
write-output "unmounting default user registry"
&reg unload HKLM\wimregistryuser

#done, reboot if necessary
if ($config.reboot) {
    &shutdown -r -t 0
}