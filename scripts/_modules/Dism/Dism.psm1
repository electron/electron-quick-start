#
# Script Module file for Dism module.
#
# Copyright (c) Microsoft Corporation
#

#
# Cmdlet aliases
#

Set-Alias Apply-WindowsUnattend Use-WindowsUnattend
Set-Alias Add-ProvisionedAppxPackage Add-AppxProvisionedPackage
Set-Alias Remove-ProvisionedAppxPackage Remove-AppxProvisionedPackage
Set-Alias Get-ProvisionedAppxPackage Get-AppxProvisionedPackage
Set-Alias Optimize-ProvisionedAppxPackages Optimize-AppxProvisionedPackages
Set-Alias Set-ProvisionedAppXDataFile Set-AppXProvisionedDataFile

# Below are aliases for Appx related cmdlets and aliases
Set-Alias Add-AppProvisionedPackage Add-AppxProvisionedPackage
Set-Alias Remove-AppProvisionedPackage Remove-AppxProvisionedPackage
Set-Alias Get-AppProvisionedPackage Get-AppxProvisionedPackage
Set-Alias Optimize-AppProvisionedPackages Optimize-AppxProvisionedPackages
Set-Alias Set-AppPackageProvisionedDataFile Set-AppXProvisionedDataFile
Set-Alias Add-ProvisionedAppPackage Add-AppxProvisionedPackage
Set-Alias Remove-ProvisionedAppPackage Remove-AppxProvisionedPackage
Set-Alias Get-ProvisionedAppPackage Get-AppxProvisionedPackage
Set-Alias Optimize-ProvisionedAppPackages Optimize-AppxProvisionedPackages
Set-Alias Set-ProvisionedAppPackageDataFile Set-AppXProvisionedDataFile

Export-ModuleMember -Alias * -Function * -Cmdlet *
