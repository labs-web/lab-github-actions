# Update README.md file from lab-web.json


# Le code source est dévelopé dans /labs-web/scripts/labs/update-readme-file.ps1
 
# L'utilisateur doit exécuter ce script sur la racine du lab

# Functions
function confirm_to_continue($message) {
    $title    = $message 
    $question = "Are you sure you want to proceed?"
    $choices  = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 1) { 
        exit
    } 
}
 
# Input 
$depot_path = $(Get-Location).Path
$readme_path= "$depot_path\README.md"
$lab_web_data_path = "$depot_path/lab-web.json"
$backlog_files_path = "$depot_path\backlog"

# Load json_data
$json_data = Get-Content $lab_web_data_path  | ConvertFrom-Json

# 
# Génération de contenue de fichier README
#

# Introduction
$readme_string = "# $($json_data.Introduction.Titre) `n`n"
$readme_string += "- Référence :  $($json_data.Introduction.Reference) `n`n"
$readme_string += "$($json_data.Introduction.Description) `n`n"
# Backlog
$readme_string += "## $($json_data.Backlog.Titre) `n`n"
$readme_string += "$($json_data.Backlog.Introduction) `n`n"
Get-ChildItem $backlog_files_path |  ForEach-Object {
    $backlog_item_file_name = $_.Name
    $readme_string += "- [$backlog_item_file_name](./Backlog/$backlog_item_file_name) `n"
} 
## Livrables 
$readme_string += "## $($json_data.Livrables.Titre) `n`n"
$readme_string += "$($json_data.Livrables.Introduction) `n`n"
$json_data.Livrables.Livrables |  ForEach-Object {
    $readme_string += "- $($_.Titre) `n"
    if(-not($_.Description -eq "")){
        $readme_string += "  - $($_.Description) `n"
    }
} 
## Références 
$readme_string += "## $($json_data.References.Titre) `n`n"
$readme_string += "$($json_data.References.Introduction) `n`n"

$json_data.References.References |  ForEach-Object {
    $readme_string += "- [$($_.Titre)]($($_.Lien)) `n"
} 

# Préparation de git for pullrequest
git config --global user.name "ESSARRAJ"
git config --global user.email "essarraj.fouad@gmail.com"
git fetch
$branch_update_readme_file_exist = $false
$branch_list = git branch -r
foreach($branch_name in $branch_list ){
    $branch_name = $branch_name.Trim()
    if($branch_name  -eq "origin/update-readme-file"){
        $branch_update_readme_file_exist = $true
    }
}
if($branch_update_readme_file_exist){
    Write-Host "git checkout update-readme-file"
    git checkout "update-readme-file"
}else{
    Write-Host "git checkout -b update-readme-file"
    git checkout -b "update-readme-file" 
    git push --set-upstream origin update-readme-file
}
git pull

# Enregistrement de fichier README
Set-Content $readme_path $readme_string

# push to  update-readme-file branch
git add .
git commit -m "change README.md file to be updated with lab-web.json"
git push

# Create pull request if not yet exist
$pull_request_exist = (gh pr list --json title | ConvertFrom-Json).title -contains "update readme file"
if(-not($pull_request_exist)){
    gh pr create --base develop --title "update readme file" --body "change README.md to lab-web.json"
}

