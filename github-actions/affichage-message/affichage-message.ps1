
$message_erreur = "::error::  Vous n'avez pas le droit de modifier le fichier 1"
Write-Host $message_erreur
Write-Host "::error file=app.js,line=1::Missing semicolon"
Write-Host "::debug::Set the Octocat variable"
# Write-error $message_erreur
exit 1 