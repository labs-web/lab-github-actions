# Create or updat backlog to issues

# Configutation de script
$project_name = "labs-web"


# Le sctipy doit être exécuter dans la racine de dépôt

# 
# Description
# 
# - Création des issues 
# - Mise à jour des issues 
# - Affectation de l'issue à TeamPlanning
# - Nom de fichier : 1.nom_issue.23.md

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$prev = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


#
# Functions : Message de confirmation
#

function confirm_to_continue($message) {
      
  $title    = $message 
  $question = "Are you sure you want to proceed?"
  $choices  = '&Yes', '&No'

  Write-Host $message 
  
  # $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
  # if ($decision -eq 1) {
  #  exit
  # } 
}

$branche_name = ""
function create_branch_to_do_pull_request {

  $branche_name = "update_backlog_files-" + (Get-Date).ToString('MM-dd-yyyy-hh-mm-ss')
  git config --global user.name "ESSARRAJ"
  git config --global user.email "essarraj.fouad@gmail.com"
  git checkout -b $branche_name 
  git push --set-upstream origin update_backlog_files
  git pull

  # Préparation de git for pullrequest
  # git config --global user.name "ESSARRAJ"
  # git config --global user.email "essarraj.fouad@gmail.com"
  # git fetch
  # $branch_update_backlog_files_exist = $false
  # $branch_list = git branch -r
  # foreach($branch_name in $branch_list ){
  #     $branch_name = $branch_name.Trim()
  #     if($branch_name  -eq "origin/update_backlog_files"){
  #         $branch_update_backlog_files_exist = $true
  #     }
  # }
  # if($branch_update_backlog_files_exist){
  #     Write-Host "git checkout update_backlog_files"
  #     git checkout "update_backlog_files"
  #     git merge develop
  # }else{
  #     Write-Host "git checkout -b update_backlog_files"
  #     git checkout -b "update_backlog_files" 
  #     git push --set-upstream origin update_backlog_files
  # }
  # git pull
  
}
  
function save_and_send_pullrequest(){
  # push to  update_backlog_files branch
git add .
git commit -m "change backlog files"
git push

# Create pull request if not yet exist
$pull_request_exist = (gh pr list --json title | ConvertFrom-Json).title -contains "change backlog files"
if(-not($pull_request_exist)){
    gh pr create --base develop --title "$branche_name" --body "change backlog files"
}

}

# get organisation name

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

function get_issue_object([String]$file_name, [String] $file_fullname){
  $item_full_path = Split-Path  -Path $file_fullname
  # Règle : L'issue est existe si le fichier item commence par le numéro de l'issue
  # Exemple des nom 
  # issue: 2.conception.10.md : 2:ordre,conception:title,10:numéro de l'issue sur github
  # order_file:   3.codage.md
  # create_file : test.md
  # State : create_file,order_file,issue
  $Issue_obj = [PSCustomObject]@{ordre = 0
    number =  0
    title = ''
    labels = ''
    state = ''
    member = $null
  }
  $file_name_array = $file_name.Split(".")
  # si file is issue : l'élément avant dernier est un nombre
  $last_element_index = $file_name_array.Length - 1 
  $avant_dernier_element = $file_name_array[$last_element_index - 1]
  $first_element = $file_name_array[0]


  # Titre : si l'avant dernier élémet est un nombre 
  if($avant_dernier_element -match "^\d+$")
  {
    $Issue_obj.number = $avant_dernier_element
    $Issue_obj.title = $file_name_array[$last_element_index - 2]
  } else
  {
    $Issue_obj.title = $file_name_array[$last_element_index - 1]
    $Issue_obj.number = 0
  }


  # si number = 0 et issue existe dans github
  $issue = find_issue_by_title $Issue_obj.title
  if($Issue_obj.number -eq 0){
    if(-not($issue -eq $null)){
      $Issue_obj.number = $issue.number
    }
  }
    
  # Dection de membre 
  $membre_title_array = $Issue_obj.title.Split("_")
  if($membre_title_array.Length -eq 2){
    $Issue_obj.member = $membre_title_array[0]
  }else{ 
    $Issue_obj.member = $null
  }
   
    
  # L'odre est le premier nombre
  if($first_element -match "^\d+$") { 
    $Issue_obj.ordre = $first_element
  } 
  else{ 
    $Issue_obj.ordre = "0"
  }
  
  
  return $Issue_obj
}

# Input
$depot_path = Get-Location


# Message de confirmation
confirm_to_continue("Update or Create issues for repository : $depot_path ")



create_branch_to_do_pull_request

# Traitement pour chaque fichier(item) dans /backlog
Get-ChildItem "$depot_path/backlog" -Filter *.md | 
Foreach-Object {

    # file name and path
    $file_fullname = $_.FullName
    $file_name = $_.Name
    $item_full_path = Split-Path  -Path $file_fullname
    # issue_object
    $Issue_obj = get_issue_object $file_name  $file_fullname

    # Create new issue 
    if($Issue_obj.number -eq 0){
            confirm_to_continue("Création de l'issue : $Issue_obj ")
            if($Issue_obj.member -eq $null){
              confirm_to_continue("gh issue create --title $($Issue_obj.title)--label feature,new_issue --project $project_name  --body-file $file_fullname")
              # gh issue create --title $Issue_obj.title--label feature,new_issue --project $project_name  --body-file $file_fullname
              gh issue create --title $Issue_obj.title--label feature,new_issue  --body-file $file_fullname
            }else{
              confirm_to_continue("gh issue create --title $($Issue_obj.title) --label feature,new_issue --assignee $($Issue_obj.member)  --project $project_name  --body-file $file_fullname ")
              gh issue create --title $Issue_obj.title --label feature,new_issue --assignee $Issue_obj.member  --project $project_name  --body-file $file_fullname 
            }
    }else{
        # Edit existant issue
        # $Issue_obj.title += "test"
        confirm_to_continue("gh issue edit $($Issue_obj.number) --title $($Issue_obj.title) --add-label feature,new_issue --body-file $file_fullname")
        # gh issue edit $Issue_obj.number --title $Issue_obj.title --add-label feature,new_issue --add-project $project_name --body-file $file_fullname
        gh issue edit $Issue_obj.number --title $Issue_obj.title --add-label feature,new_issue --body-file $file_fullname
    }

    # Change file name if is incorrect
    $Issue_obj_file_name = "$($Issue_obj.ordre).$($Issue_obj.title).$($Issue_obj.number).md"
    if(-not($Issue_obj_file_name -eq $file_name )){
        # Update file name
        Write-Host "Rename $file_name to $Issue_obj_file_name "
        Write-Host "$file_fullname"
        Write-Host "$item_full_path\$Issue_obj_file_name"
        Rename-Item -Path $file_fullname -NewName "$item_full_path/$Issue_obj_file_name"
    }

}

save_and_send_pullrequest

# send pull request 

