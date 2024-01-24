
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
  debug "Remot branches :  $branch_list "
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

# Préparation de git for pullrequest
function create_branch_to_do_pull_request ($branche_name) {

  debug "Création ou changeement de branch : $branche_name  "

  git config --global user.name "ESSARRAJ"
  git config --global user.email "essarraj.fouad@gmail.com"
  git add .
  git commit -m "save to run update-issue-from-backlog.ps1"

  # Delete remote branch 
  # On peut pas vérifier l'existance de branch avant de le supprimer sur github action runnner 
  # because checkout@v4 can clone one branch 
  # donc, cette commande affiche une erreur si la branche n'existe pas sur github
  confirm_to_continue("run git push origin --delete $branche_name ")
  git push origin --delete $branche_name 


  # Delete local branch if exist
  debug "Delete local branch $branche_name "
  git branch -D $branche_name
  git checkout -b $branche_name

}

function save_and_send_pullrequest($branche_name){
  debug "Création de pullrequest pour enregistrer les modification de backlog files"
  confirm_to_continue("run : git push --set-upstream origin $branche_name")
  git push --set-upstream origin $branche_name
  git pull
  
  # push to  $branche_name branch
  confirm_to_continue("run : git push")
  git add .
  git commit -m "$branche_name"
  git push
  
  # Create pull request if not yet exist
  debug "Create pull request if not yet exist"
  confirm_to_continue "run : gh pr create --base develop --title $branche_name --body 'change backlog files'"
  $pull_request_exist = (gh pr list --json title | ConvertFrom-Json).title -contains "$branche_name"
  if(-not($pull_request_exist)){
      gh pr create --base develop --title $branche_name --body $branche_name
  }

}