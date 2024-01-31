# Create or updat backlog to issues

. "./scripts/core/core.ps1"
. "./scripts/core/issue.core.ps1"
. "./scripts/core/pullrequest-core.ps1"
# Core : Params
$debug = $true
$test = $false
$confirm_message = $false

# Global variable
$branche_name = "update_backlog_files"

# $project_name = "labs-web"
$project_name = $args[0]
if ($project_name -ne $null) {
  Write-Host "Variable exists"
  debug("project_name exist = $project_name")
} else {
  $project_name = "labs-web"
  debug("project_name not exist = $project_name")
}

$depot_path = Get-Location


# Message de confirmation
confirm_to_continue("Update or Create issues for repository : $depot_path ")

# Issue_obj : convert backlog_item_file to issue_obj
function get_issue_object([String]$file_name, [String] $file_fullname){
  # $item_full_path = Split-Path  -Path $file_fullname
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
    body_file = $file_fullname
    file_name = $file_name
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
  # Detection de membre 
  $membre_title_array = $Issue_obj.title.Split("_")
  if($membre_title_array.Length -eq 2){
    $Issue_obj.member = $membre_title_array[0]
  }else{ 
    $Issue_obj.member = $null
  }
  # L'odre est le premier nombre
  if($first_element -match "^\d+$") { 
    $Issue_obj.ordre = $first_element
  } else{ 
    $Issue_obj.ordre = "0"
  }
  return $Issue_obj
}

# Create new issue from $Issue_obj 
function create_issue($Issue_obj,$label){

  debug("Issue_obj : $Issue_obj ")
  if($Issue_obj.member -eq $null){
    debug "Création nouvelle issue :  $($Issue_obj.title) "
    confirm_to_continue("run : gh issue create --title $($Issue_obj.title)--label $label,new_issue --project $project_name  --body-file $($Issue_obj.body_file)")
    gh issue create --title $Issue_obj.title--label $label,new_issue --project $project_name  --body-file $($Issue_obj.body_file)
    
    # Change $Issue_obj.number
    $remote_issue = find_issue_by_title $Issue_obj.title
    $Issue_obj.number = $remote_issue.number

    # Change file name 
  }else{
    debug "Création nouvelle issue :  $($Issue_obj.title) pour membre $($Issue_obj.member) "
    confirm_to_continue("run : gh issue create --title $($Issue_obj.title) --label $label,new_issue --assignee $($Issue_obj.member)  --project $project_name  --body-file $($Issue_obj.body_file) ")
    gh issue create --title $Issue_obj.title --label $label,new_issue --assignee $Issue_obj.member  --project $project_name  --body-file $($Issue_obj.body_file)
  }
}

function edit_issue($Issue_obj,$label){
  debug "Edition de l'issue #$($Issue_obj.number) : $($Issue_obj.title)"
  confirm_to_continue("run gh issue edit $($Issue_obj.number) --title $($Issue_obj.title) --add-label $label,new_issue --add-project $project_name --body-file $($Issue_obj.body_file)")
  gh issue edit $Issue_obj.number --title $Issue_obj.title --add-label $label --add-project $project_name --body-file $($Issue_obj.body_file)
}

function change_backlog_item_file_name($Issue_obj){
  # debug "Rename file : $Issue_obj"
  $Issue_obj_file_name = "$($Issue_obj.ordre).$($Issue_obj.title).$($Issue_obj.number).md"
    if(-not($Issue_obj_file_name -eq $Issue_obj.file_name )){
        # Update file name
        debug "Rename $file_name to $Issue_obj_file_name "
        debug "- Source : $file_fullname"
        debug "- Destination : $item_full_path\$Issue_obj_file_name"
        Rename-Item -Path $file_fullname -NewName "$item_full_path/$Issue_obj_file_name"
        return $true
    }
    return $false
}

$add_or_update_issues_iteration = 0
function add_or_update_issues($directory, $label){

 

  debug "----`n - Update or Create issues for : $label `n - ----"

  $backlog_items=  Get-ChildItem $directory -Filter *.md  
  $add_or_update_issues_chaned_files = $false
  foreach($backlog_item in $backlog_items) {
    # file name and path
    $file_fullname = $backlog_item.FullName
    $file_name = $backlog_item.Name
    $item_full_path = Split-Path  -Path $file_fullname
    # CreateIssue_obj that represente backlog_itm_file
    $Issue_obj = get_issue_object $file_name  $file_fullname
    if($Issue_obj.number -eq 0){ create_issue $Issue_obj $label
    }else{ edit_issue $Issue_obj $label }

    # Change backlog_item_file name
    $change_backlog_item_file_name_retuen_value = change_backlog_item_file_name $Issue_obj

     # if not yet true
    if($change_backlog_item_file_name_retuen_value) {
      $add_or_update_issues_chaned_files = $true  
    }

    # En cas de test traiter un seul fichier par dossier
    if($test ) { break }

  }
  return $add_or_update_issues_chaned_files
}

# Create or Update issues
create_branch_to_do_pull_request $branche_name  
$chaned_files = $false
$backlog_directories=  Get-ChildItem "$depot_path/backlog"  -Directory
foreach($backlog_directory in $backlog_directories) {
    # Ne pas traiter les dossier qui commance par "_"
    if($backlog_directory.Name -like "_*") {continue}
    $label = $backlog_directory.Name
    $directory = $backlog_directory.FullName 
    $return_value = add_or_update_issues $directory $label
    
    # if not yet true
    if(-not($chaned_files)) {
      $chaned_files = $return_value[$return_value.lenght - 1]
    }
    
    
}
save_and_send_pullrequest_if_files_changes $branche_name $chaned_files 
