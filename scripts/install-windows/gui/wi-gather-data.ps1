$config = @{}
import-module "$psscriptroot\..\..\_modules\dism\dism.psd1"

$drives = get-ciminstance win32_diskdrive | select-object index, caption, size, serialnumber | sort-object { $_.index }
foreach ($drive in $drives) {
    $drive.size = [int]($drive.size / 1000000000)
    $drive.caption = $drive.caption + " ($($drive.size)GB, SN: $($drive.serialnumber))"
}

$config.driveIndex = [Int[]]$drives.index
$config.driveCaption = [String[]]$drives.caption

$images = Get-WindowsImage -ImagePath $args[0] | select-object -property "ImageIndex", "ImageName", "ImageDescription"
$config.imageName = [String[]]$images.imageName
$config.imageIndex = [Int[]]$images.imageIndex

$config.Installers = [String[]]((Get-ChildItem $psscriptroot\..\..\..\assets\installers).name)

ConvertTo-Json $config