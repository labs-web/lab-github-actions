
# Encoding UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$prev = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


#
# Functions : Message de confirmation
#

function debug($message){
    if($debug){
      Write-Host "`n - $message "
    }
  }
