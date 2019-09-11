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

