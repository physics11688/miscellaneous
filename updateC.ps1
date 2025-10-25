# C環境のアップデート

<#
    .SYNOPSIS
        LLVM と MinGW の自動アップデートを行う
    .NOTES
        PowerShell 7+ 対応
    #>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
$mingwPath = "$HOME\mingw64"
$gccPath = Join-Path $mingwPath "bin\gcc.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7zr.exe"
$githubApiUrl = "https://api.github.com/repos/niXman/mingw-builds-binaries/releases/latest"

try {
    Write-Host "`n=== LLVMのアップデート ==="
    winget upgrade --id LLVM.LLVM --accept-source-agreements --accept-package-agreements | Out-Host
}
catch {
    Write-Warning "LLVM のアップデートでエラーが発生しました: $_"
}

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

# 既存バージョンチェック
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

# 作業用フォルダ
$tempDir = Join-Path $env:TEMP "mingw_update"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null
Set-Location $tempDir

# 7zr.exe の取得
Write-Host "`n7-Zip展開ツールをダウンロード中..."
Invoke-WebRequest -Uri $sevenZipUrl -OutFile "7zr.exe"

# MinGWダウンロード
Write-Host "MinGWをダウンロード中..."
$archiveName = Split-Path $URL -Leaf
Invoke-WebRequest -Uri $URL -OutFile $archiveName

# 解凍
Write-Host "解凍中..."
& .\7zr.exe x $archiveName | Out-Null

if (-not (Test-Path ".\mingw64")) {
    Write-Error "mingw64 フォルダが見つかりません。展開に失敗した可能性があります。"
    return
}

# 上書きインストール
Write-Host "`n$HOME\mingw64\mingw64 にインストール中..."
if (Test-Path $mingwPath) {
    Remove-Item -Recurse -Force $mingwPath
}
Move-Item -Path ".\mingw64" -Destination "$HOME" -Force

# クリーンアップ
Set-Location $HOME  # ← ★ 一旦ホームに戻る
Remove-Item -Recurse -Force $tempDir

# 確認
$newVersion = & $gccPath -dumpversion
if ($currentVersion) {
    Write-Host "`nMinGWは $currentVersion → $newVersion に更新されました。"
}
else {
    Write-Host "`nMinGW $newVersion のインストールが完了しました。"
}

Write-Host "`nPATH: $mingwPath"
