# Update README file for lab
# Le code source est dévelopé dans /labs-web/scripts/labs/update-readme-file.ps1
 
# Functions : confirmation
function confirm_to_continue($message) {
    $title    = $message 
    $question = "Are you sure you want to proceed?"
    $choices  = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 1) { 
        exit
    } 
}
 
# L'utilisateur doit exécuter ce script sur le racine du lab
# confirm_to_continue("Vous devez exécuter ce script sur la racine du lab")

# Paths 
$depot_path = $(Get-Location).Path
$readme_path= "$depot_path\README.md"
$lab_web_data = "$depot_path/lab-web.json"
$backlog_files_path = "$depot_path\Backlog"
# Confirmation
# confirm_to_continue("Update de fichier $readme_path ")


# Load JSON
$json_data = Get-Content $lab_web_data  | ConvertFrom-Json


# Création de fichier README

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

# Enregistrement de fichier README
Set-Content $readme_path $readme_string
