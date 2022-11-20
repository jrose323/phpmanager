$foundCert = Test-Certificate -Cert Cert:\CurrentUser\my\8ef9a86dfd4bd0b4db313d55c4be8b837efa7b77 -User
if(!$foundCert)
{
    Write-Host "Certificate doesn't exist. Exit."
    exit
}

Write-Host "Certificate found. Sign the assemblies."
$signtool = "C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe"
foreach ($line in Get-Content .\sign.txt) {
    & $signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a .\$line | Write-Debug
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host ".\bin\$line is not signed. Exit."
        exit $LASTEXITCODE
    }
}

Write-Host "Verify digital signature."
$files = Get-ChildItem .\bin\Release\* -Include ("*.dll", "*.exe") -Exclude ("Microsoft.*") -File
$files | ForEach-Object {
    & $signtool verify /pa /q $_ 2>&1 | Write-Debug
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "$_ is not signed. Exit."
        exit $LASTEXITCODE
    }
}

Write-Host "Verification finished."
