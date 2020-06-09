#give off initial info about the computer
$info = @{}
$info["Model Number"] = (get-ciminstance win32_computersystem).manufacturer + " " + (get-ciminstance win32_computersystem).model
new-object -type pscustomobject -property $info | convertto-html

$info = @{}
$info["Serial Number"] = (get-ciminstance win32_bios).SerialNumber
new-object -type pscustomobject -property $info | convertto-html

$info = @{}
$info["Ram"] = [string]([int]((get-ciminstance -class "cim_physicalmemory" | ForEach-Object {$_.Capacity} | measure-object -sum).sum / 1GB)) + " GB"
new-object -type pscustomobject -property $info | convertto-html

$info = @{}
$info["Size of Hard-Drive"] = [string][int]((get-ciminstance win32_diskdrive | where-object {$_.index -eq 0}).size / 1000000000) + " GB"
new-object -type pscustomobject -property $info | convertto-html

$info = @{}
$info["CPU"] = (get-ciminstance win32_processor).Name
new-object -type pscustomobject -property $info | convertto-html