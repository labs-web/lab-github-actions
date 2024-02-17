
$message_erreur = "::error::  Message 1"
Write-Host $message_erreur
Write-Host "::error file=app.js,line=1::Missing semicolon"
# Write-error $message_erreur
exit 1 