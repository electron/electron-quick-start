$drives = get-psdrive -PSProvider "filesystem"

foreach ($drive in $drives) {
    if(test-path ("$($drive.name):\sources\install.wim")) {
        write-host "$($drive.name):\sources\install.wim"
        exit
    }
    if(test-path ("$($drive.name):\sources\install.swm")) {
        write-host "$($drive.name):\sources\install.swm"
        exit
    }
}
#we didnt' detect anything, so error out
throw "no wim files autodetected"