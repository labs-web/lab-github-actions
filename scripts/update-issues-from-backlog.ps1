﻿# Create or updat backlog to issues


# Configutation de script
$project_name = "labs-web"
$debug = $true
$confirm_message = $true

Write-Host "Start Import-Module ./scripts/cor.psm1"
# Import-Module ./scripts/cor.psm1
. "./scripts/cor.psm1"
Write-Host "end Import-Module ./scripts/cor.psm1"




# Global variable
# $branche_name = "update_backlog_files-" + (Get-Date).ToString('MM-dd-yyyy-hh-mm-ss')
$branche_name = "update_backlog_files"

# Le sctipy doit être exécuter dans la racine de dépôt

# 
# Description
# 
# - Création des issues 
# - Mise à jour des issues 
# - Affectation de l'issue à TeamPlanning
# - Nom de fichier : 1.nom_issue.23.md

# $PSDefaultParameterValues['*:Encoding'] = 'utf8'
# $prev = [Console]::OutputEncoding
# [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


# Run cor script
$depot_path = Get-Location






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

# Préparation de git for pullrequest
function create_branch_to_do_pull_request {

  debug "Création ou changeement de branch : $branche_name  "

  # Solutin 1 : 

  git config --global user.name "ESSARRAJ"
  git config --global user.email "essarraj.fouad@gmail.com"
  git add .
  git commit -m "save to run update-issue-from-backlog.ps1"

  # Delete remote branch 
  $remote_branch_exist = if_remote_branch_exist ($branche_name)
  debug "Delete remote branch : remote_branch_exist = $remote_branch_exist "
  if( $remote_branch_exist ){
    confirm_to_continue("run git push origin --delete update_backlog_files ")
    git push origin --delete update_backlog_files 
  }
  
  # Delete local branch if exist
  debug "Delete local branch update_backlog_files "
  git branch -D update_backlog_files
  git checkout -b update_backlog_files


  # Solution 2 : 

  # git config --global user.name "ESSARRAJ"
  # git config --global user.email "essarraj.fouad@gmail.com"
  # # Save local change in develop branche befor checkout update_backlog_files
  # git add .
  # git commit -m "save to run update-issue-from-backlog.ps1"

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
  #     confirm_to_continue "run : git checkout update_backlog_files"
  #     git checkout "update_backlog_files"
  #     debug "Merge develop pour mettre à jour la branch "
  #     confirm_to_continue "run : git merge develop"
  #     git merge develop
  # }else{
  #     Write-Host "git checkout -b update_backlog_files"
  #     git checkout -b "update_backlog_files" 
  #     git push --set-upstream origin update_backlog_files
  # }

  # ??
  # git pull  
  
}
  
function save_and_send_pullrequest(){
debug "Création de pullrequest pour enregistrer les modification de backlog files"
confirm_to_continue("run : git push --set-upstream origin $branche_name")
git push --set-upstream origin $branche_name
git pull

# push to  update_backlog_files branch
confirm_to_continue("run : git push")
git add .
git commit -m "change backlog files"
git push

# Create pull request if not yet exist
debug "Create pull request if not yet exist"
confirm_to_continue "run : gh pr create --base develop --title $branche_name --body 'change backlog files'"
$pull_request_exist = (gh pr list --json title | ConvertFrom-Json).title -contains "$branche_name"
if(-not($pull_request_exist)){
    gh pr create --base develop --title $branche_name --body "change backlog files"
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
$chaned_files = $false
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
              debug "Création nouvelle issue :  $($Issue_obj.title) "
              confirm_to_continue("run : gh issue create --title $($Issue_obj.title)--label feature,new_issue --project $project_name  --body-file $file_fullname")
              gh issue create --title $Issue_obj.title--label feature,new_issue --project $project_name  --body-file $file_fullname
              # gh issue create --title $Issue_obj.title--label feature,new_issue  --body-file $file_fullname
            }else{
              debug "Création nouvelle issue :  $($Issue_obj.title) pour membre $($Issue_obj.member) "
              confirm_to_continue("run : gh issue create --title $($Issue_obj.title) --label feature,new_issue --assignee $($Issue_obj.member)  --project $project_name  --body-file $file_fullname ")
              gh issue create --title $Issue_obj.title --label feature,new_issue --assignee $Issue_obj.member  --project $project_name  --body-file $file_fullname 
            }
    }else{
        # Edit existant issue
        # $Issue_obj.title += "test"
        debug "Edition de l'issue #$Issue_obj.number : $($Issue_obj.title)"
        confirm_to_continue("run gh issue edit $($Issue_obj.number) --title $($Issue_obj.title) --add-label feature,new_issue --add-project $project_name --body-file $file_fullname")
        # gh issue edit $Issue_obj.number --title $Issue_obj.title --add-label feature,new_issue --add-project $project_name --body-file $file_fullname
        gh issue edit $Issue_obj.number --title $Issue_obj.title --add-label feature,new_issue --add-project $project_name --body-file $file_fullname
    }

    # Change file name if is incorrect
    $Issue_obj_file_name = "$($Issue_obj.ordre).$($Issue_obj.title).$($Issue_obj.number).md"
    if(-not($Issue_obj_file_name -eq $file_name )){
        # Update file name
        debug "Rename $file_name to $Issue_obj_file_name "
        debug "- Source : $file_fullname"
        debug "- Destination : $item_full_path\$Issue_obj_file_name"
        Rename-Item -Path $file_fullname -NewName "$item_full_path/$Issue_obj_file_name"
        $chaned_files = $true
    }

}

debug "Send pullrequest si changed file, chaned_files = $chaned_files "
if($chaned_files){
  save_and_send_pullrequest
}
git checkout develop
# send pull request 

