
# Input
$param1 = $args[0]
$package_name = $param1.Split('/')[0]

# Changed files
$chanded_files = git diff --name-only HEAD^1 HEAD


# Les dossiers autorisé pour le package $package_name

$autorized_directories = "app/Http/Controllers/$package_name",
                 "app/Models/$package_name",
                 "docs/$package_name"

# Message d'erreur
$message_erreur = ""

foreach($file in $chanded_files){
    $autorised_change = $false
    foreach($autorized_directory in $autorized_directories ){
        if($file -like "$autorized_directory*"){
            $autorised_change = $true
        }
    }
    if(-not($autorised_change)) {
        $message_erreur =  $message_erreur + "Vous n'avez pas le droit de modifier le fichier : $file `n"
    } 
}

if(-not($message_erreur -eq "")){
    Write-Host $message_erreur
    exit 1
}



# Filtrer les fichiers selon une expression regulière
# $filteted_files =  $chanded_files | Where-Object { 
#     $_ -match '^github' -or $_ -match '.php$' 
# }

# Affichage
# foreach ($file in  $filteted_files){
#     Write-Host $file
# }
# \app\Http\Controllers\Package1

