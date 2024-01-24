
# Encoding UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$prev = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$debug = $true
$confirm_message = $true

#
# Functions : Message de confirmation
#

#
# Functions : Message de confirmation
#

function debug($message){
  if($debug){
    Write-Host "`n - $message "
  }
}


function confirm_to_continue($message) {
      
    $title    = $message 
    $question = "Are you sure you want to proceed?"
    $choices  = '&Yes', '&No'
  
    if($confirm_message){
      $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 1) {
        exit
      } 
    }else{
      if($debug){
        Write-Host "`n - $message `n"
      }
    }
  }

Write-Host "Run core ps1"

confirm_to_continue("Exécution de cor.ps1")
