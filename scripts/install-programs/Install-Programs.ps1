push-location $PSScriptRoot

$installers = gci ".\files\deploy\installers\*" | select "name","fullname" | out-gridview -passthru
foreach ($installer in $installers) {
    push-location $installer.fullname
    &"$pwd\install.ps1"
    pop-location
}