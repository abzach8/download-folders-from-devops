# PowerShell script to download folders and all its contents from Azure Devops repos

function RepoDownload ($devopspath)
{
$filePath = "*"+ $devopspath + "/*"
$urlDownloadItems = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$($repoName)/items?recursionLevel=Full&api-version=5.0"
$itemPaths = Invoke-RestMethod -Uri $urlDownloadItems -Method Get -ContentType "application/text" -Headers $header
Write-Host "`nDownload started from $filePath..." -ForegroundColor Yellow
foreach ($i in $itemPaths.value) 
{
if (-not($i.path -like $filePath))
    {
        continue
    }
    
    if ($i.isFolder -like "True") 
    {
        New-Item -ItemType Directory -Force -Path "$localpath$($i.path)" | Out-Null
    }
    else 
    {
    $path = "$localpath$($i.path)"
    $folderPath = $path.Substring(0, $path.LastIndexOf('/'))
    if (-not(Test-Path -Path $folderPath)) 
    {
    New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
}
        $urlDownloadItem = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$($repoName)/items?path=$($i.path)&download=true&api-version=5.0"
        $fullPath = "$($localpath)$($i.path)"
        Invoke-RestMethod -Uri $urlDownloadItem -Method Get -ContentType "application/text" -Headers $header -OutFile $fullPath
    }
}
Write-Host "`nFinished downloading from $filePath" -ForegroundColor Green
}

# Code starts from here
Write-Host "`nScript started.." -ForegroundColor Yellow
Write-Host "************************" -ForegroundColor White -BackgroundColor Black
$organization = Read-Host -Prompt "Enter Devops organization name"
$project = Read-Host -Prompt "Enter Devops project name"
$repoName = Read-Host -Prompt "Enter Devops repo name"
$filePath = Read-Host -Prompt "Enter Devops path to download from"
$localpath = $PSScriptRoot
$tokenInSecureString = Read-Host "Enter personal access token (PAT)" -AsSecureString
$dummyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeUser', $tokenInSecureString
$base64AuthString = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $dummyCredential.GetNetworkCredential().Password)))
$header = @{
    "Authorization" = ("Basic {0}" -f $base64AuthString)
}
RepoDownload ($filePath)