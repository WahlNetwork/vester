$modname = 'Vester'
Import-Module -Name "$PSScriptRoot\..\$modname" -Force
$verbs = (Get-Command -Module $modname).Verb | Select-Object -Unique
 
foreach ($verb in $verbs)
{
  $data = @()  
  $data += "$verb Commands"
  $data += '========================='
  $data += ''
  $data += "This page contains details on **$verb** commands."
  $data += ''
  foreach ($help in (Get-Command -Module $modname | Where-Object -FilterScript {
        $_.name -like "$verb-*"
  }))
  {
    $data += $help.Name
    $data += '-------------------------'
    $data += ''
    $data += Get-Help -Name $help.name -Detailed
    $data += ''
  }

  $data | Out-File -FilePath "$PSScriptRoot\cmd_$($verb.ToLower()).rst" -Encoding utf8
}
