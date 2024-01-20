
# Input
$package_name = "Package1"

# Changed files
$chanded_files = git diff --name-only HEAD^ HEAD

# Filtrer les fichiers selon une expression regulière
$filteted_files =  $chanded_files | Where-Object { 
    $_ -match '^github' -or $_ -match '.php$' 
}

# Affichage
foreach ($file in  $filteted_files){
    Write-Host $file
}
# \app\Http\Controllers\Package1

