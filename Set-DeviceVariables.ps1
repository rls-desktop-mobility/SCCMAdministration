<#
    .Examples
    ### To use a single CSV file with Key Value Pairs ###
    Import-Module .\Set-DeviceVariables.ps1
    set-devicevariables -computer $(Import-CSV C:\Temp\complist.csv -header Key,Value).Key -CSVFilePath C:\Temp\complist.csv
    
    ### To use against a list of devices and apply a single variable set ###
    Import-Module .\Set-DeviceVariables.ps1
    set-devicevariables -computer $(Import-CSV C:\Temp\complist.csv -header ComputerName).ComputerName -Key "VariableKeyName" -Value "VariableValue"
    
    ### To use against a list of devices pulled from a collection or pipeline ###
    Import-Module .\Set-DeviceVariables.ps1
    set-devicevariables -computer (Get-CMDevice -CollectionName "Testing on Dave").Name -key 'test' -value 'value1'
    
    (Get-CMDevice -CollectionName "Testing on Dave").Name | Foreach-Object { set-devicevariables -computer $_ -key 'test' -value 'value1'
#>
function set-devicevariables {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$true,
            ParameterSetName='KeyValuePair',
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        [Parameter(
            Mandatory=$true,
            ParameterSetName='CSVFile',
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        $Computer,
        [Parameter(
            Mandatory=$true,
            ParameterSetName='KeyValuePair',
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        [string]
        $Key,
        [Parameter(
            Mandatory=$true,
            ParameterSetName='KeyValuePair',
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        [string]
        $Value,
        [Parameter(
            Mandatory=$true,
            ParameterSetName='CSVFile',
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage="Enter the filepath of a CSV file containing comma deliminated key value pairs"
        )]
        $CSVFilePath
    )
    
    begin {
        Set-Location 'RNK:'
        if($PSBoundParameters.ContainsKey('CSVFilePath'))
        {
            if(Test-Path -Path $CSVFilePath)
            {
                $CSVData = Import-Csv -Path $CSVFilePath -Header 'Key','Value'
                $KeyArray = @()
                $ValueArray = @()
                $CustomArray = @()
                foreach ($key in $CSVData.Key)
                {
                    $KeyArray += $Key
                }

                foreach ($value in $CSVData.Value)
                {
                    $ValueArray += $value
                }

                while ($Computer)
                {
                    $x, $Computer = $Computer
                    $y, $KeyArray = $KeyArray
                    $z, $ValueArray = $ValueArray
                    $CustomArray += [PSCustomObject]@{
                        Computer = $x
                        Key = $y
                        Value = $z
                    }
                }
            } else {
                return Write-Host "Please check the CSV File Path"
            }
        }
    }
    
    process {
        if($PSBoundParameters.ContainsKey('CSVFilePath'))
        {
            foreach ($obj in $CustomArray) {
                New-CMDeviceVariable -DeviceName $obj.Computer -VariableName $obj.Key -VariableValue $obj.Value
            }
        }
        else 
        {
            foreach ($Device in $Computer) 
            {
                New-CMDeviceVariable -DeviceName $Device -VariableName $Key -VariableValue $Value      
            }    
        }

        
    }
    end {
        return
    }
}

