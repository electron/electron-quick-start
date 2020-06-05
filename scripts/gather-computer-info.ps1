#give off initial info about the computer
$info = @{}
$info.model = (get-ciminstance win32_computersystem).manufacturer + " " + (get-ciminstance win32_computersystem).model
$info.serialnumber = (get-ciminstance win32_bios).SerialNumber
$info.ram = [string]([int]((get-ciminstance -class "cim_physicalmemory" | ForEach-Object {$_.Capacity} | measure-object -sum).sum / 1GB)) + " GB"
$info.hddSize = [string][int]((get-ciminstance win32_diskdrive | where-object {$_.index -eq 0}).size / 1000000000) + " GB"
$info.CPU = (get-ciminstance win32_processor).Name
$info.GetEnumerator() | Select-Object Key,Value | convertto-html -Fragment