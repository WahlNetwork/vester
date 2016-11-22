$Data = @{}

$Data.function1 = @{
    Name = 'Invoke-Vester'
    Parameters = @(
        @{'Name' = 'Config'; 'type' = 'object[]'; 'Mandatory' = $False; 'ValueFromPipeline' = $True; 'ValueFromPipelinebyPropertyName' = $True; 'Aliases' = @('FullName')},
        @{'Name' = 'Test'; 'type' = 'object[]'; 'Mandatory' = $False; 'ValueFromPipeline' = $False; 'ValueFromPipelinebyPropertyName' = $False; 'Aliases' = @('Path','Script')},
        @{'Name' = 'Remediate'; 'type' = 'SwitchParameter'; 'Mandatory' = $False; 'ValueFromPipeline' = $False; 'ValueFromPipelinebyPropertyName' = $False},
        @{'Name' = 'XMLOutputFile'; 'type' = 'object'; 'Mandatory' = $False; 'ValueFromPipeline' = $False; 'ValueFromPipelinebyPropertyName' = $False}
    )
}

$Data.function2 = @{
    Name = 'New-VesterConfig'
    Parameters = @(
        @{'Name' = 'OutputFolder'; 'type' = 'object'; 'Mandatory' = $False; 'ValueFromPipeline' = $False; 'ValueFromPipelinebyPropertyName' = $False},
        @{'Name' = 'Quiet'; 'type' = 'SwitchParameter'; 'Mandatory' = $False; 'ValueFromPipeline' = $False; 'ValueFromPipelinebyPropertyName' = $False}
    )
}






