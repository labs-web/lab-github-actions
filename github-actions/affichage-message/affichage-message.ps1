
$message_erreur = "::error::  Vous n'avez pas le droit de modifier le fichier 1"
Write-Host $message_erreur
Write-Host "::error file=app.js,line=1::Missing semicolon"
Write-Host "::debug::Set the Octocat variable"
Write-Host "::notice file=app.js,line=1,col=5,endColumn=7::Missing semicolon"
Write-Host "::warning file=app.js,line=1,col=5,endColumn=7::Missing semicolon"


Write-Host "::group:: Validation "
Write-Host "Message 1"
Write-Host "Message 2"
Write-Host "::endgroup::"


# Write-error $message_erreur
exit 1 