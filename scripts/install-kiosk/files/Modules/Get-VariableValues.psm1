function Get-VariableValues {
    <#
    .SYNOPSIS
        This module will take variables in a Config file denoted by the "$($Var)" signature, and expand variables with the same
        name found in the $Config PSObject. It will return a string with the expanded variables.
    .PARAMETER Config
        A PSObject with all the variables we want to translate
    .PARAMETER Content
        A string that we are performing the translate option on
    #>

    #---------------------------------------------------------[Parameters]--------------------------------------------------------

    param(
        [parameter(ParameterSetName = 'cmd', Mandatory = $true)] $Config,
        [parameter(ParameterSetName = 'cmd', Mandatory = $true)] [string]$Content
    )
    [string]$finalString

    #split the Content by the $$ variable
    $splitContent = $Content -split '(\$\(\$.*?\))'
    
    foreach ($string in $splitContent) {
        if ($string -match '\$\(\$(.*?)\)') {
            $finalString += $Config.($matches[1])
        }
        else {
            $finalString += $string
        }
    }

    return $finalString
}