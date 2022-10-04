function prompt
{
    $promptString = "" + $(Get-Location) + "›"
    Write-Host $promptString -NoNewline -ForegroundColor DarkBlue
    return " "
}