<#
.SYNOPSIS
    LLVM と MinGW の自動アップデートを行い、MinGW の bin ディレクトリをユーザー PATH に追加する
.NOTES
    PowerShell 7+ 対応
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
$mingwPath = "$HOME\mingw64"
$gccPath = Join-Path $mingwPath "bin\gcc.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7zr.exe"
$githubApiUrl = "https://api.github.com/repos/niXman/mingw-builds-binaries/releases/latest"

function Add-ToUserPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$NewPath
    )

    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($currentPath -split ";" | Where-Object { $_ -eq $NewPath }) {
        Write-Host "既に PATH に含まれています: $NewPath"
    }
    else {
        $updatedPath = "$currentPath;$NewPath"
        [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")
        Write-Host "ユーザー環境変数 PATH に追加しました: $NewPath"
    }

    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $NewPath })) {
        $env:PATH += ";$NewPath"
        Write-Host "現在のセッションの PATH にも追加しました。"
    }
    else {
        Write-Host "現在のセッションの PATH にも既に含まれています。"
    }
}

try {
    Write-Host "`n=== LLVMのアップデート ==="
    winget upgrade --id LLVM.LLVM --accept-source-agreements --accept-package-agreements | Out-Host
}
catch {
    Write-Warning "LLVM のアップデートでエラーが発生しました: $_"
}

Add-ToUserPath -NewPath "C:\Program Files\LLVM\bin"

Write-Host "`n=== MinGW の最新版URL取得 ==="
try {
    $URL = (curl.exe -s $githubApiUrl |
        Select-String -Pattern "https.*x86_64.*posix-seh-ucrt.*7z" |
        ForEach-Object { $_.Matches.Value } |
        Select-Object -First 1)

    if (-not $URL) {
        throw "GitHub APIからMinGWのURLを取得できませんでした。"
    }
    Write-Host "取得URL: $URL"
}
catch {
    Write-Error $_
    return
}

$currentVersion = if (Test-Path $gccPath) { & $gccPath -dumpversion } else { $null }

if ($currentVersion -and ($URL -match [Regex]::Escape($currentVersion))) {
    Write-Host "`n現在のMinGW ($currentVersion) は最新版です。アップデート不要。"
    return
}

if ($currentVersion) {
    Write-Host "`nMinGW ($currentVersion) を最新版にアップデートします。"
}
else {
    Write-Host "`nMinGWを新規インストールします。"
}

$tempDir = Join-Path $env:TEMP "mingw_update"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null
Set-Location $tempDir

Write-Host "`n7-Zip展開ツールをダウンロード中..."
Invoke-WebRequest -Uri $sevenZipUrl -OutFile "7zr.exe"

Write-Host "MinGWをダウンロード中..."
$archiveName = Split-Path $URL -Leaf
Invoke-WebRequest -Uri $URL -OutFile $archiveName

Write-Host "解凍中..."
& .\7zr.exe x $archiveName | Out-Null

if (-not (Test-Path ".\mingw64")) {
    Write-Error "mingw64 フォルダが見つかりません。展開に失敗した可能性があります。"
    return
}

Write-Host "`n$HOME\mingw64 にインストール中..."
if (Test-Path $mingwPath) {
    Remove-Item -Recurse -Force $mingwPath
}
Move-Item -Path ".\mingw64" -Destination "$HOME" -Force

Set-Location $HOME
Remove-Item -Recurse -Force $tempDir

$newVersion = & $gccPath -dumpversion
if ($currentVersion) {
    Write-Host "`nMinGWは $currentVersion → $newVersion に更新されました。"
}
else {
    Write-Host "`nMinGW $newVersion のインストールが完了しました。"
}

Write-Host "`nPATH: $mingwPath"
Add-ToUserPath -NewPath "$mingwPath\bin"
