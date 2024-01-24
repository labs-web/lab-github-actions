
# Encoding UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$prev = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Write-Host "Import core.ps1"

# Paramètre pardéfaut
$debug = $true
$confirm_message = $true


# Debug : Afficher les message de débugage
function debug($message){
  if($debug){
    Write-Host "`n - $message "
  }
}

# Message de confirmation
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


# Trouver si une branch exist ou non
function if_remote_branch_exist($branche_name){
  $branch_list = git branch -r
  foreach($item in $branch_list ){
      $item = $item.Trim()
      if($item  -eq "origin/$branche_name"){
          return $true
      }
  }
  return $false
}


function find_issue_by_title($title){
  
  # confirm_to_continue("find $title in issues ")
  $all_issues = gh issue list --json number,title | ConvertFrom-Json
  foreach($issue in  $all_issues){
    # Write-Host $Issue_obj.title
    if($issue.title -eq $title){
      return $issue
    }
  }
  return $null
}