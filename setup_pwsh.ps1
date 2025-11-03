
# 1/5 PowerShellGet のインストール（既に入っている可能性あり）
if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
    Install-Module -Name PowerShellGet -Force -Scope CurrentUser
}

# 2/5 PSReadLine のインストール（補完機能強化）
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module PSReadLine -Force -Scope CurrentUser
}

# 3/5 Git のインストール（winget 経由、存在チェック）
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git --source winget
}

# 4/5 posh-git のインストール（PowerShellGet 経由）
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    PowerShellGet\Install-Module posh-git -Force -Scope CurrentUser
}

# 5/5 pyserial のインストール（Python モジュール）
if (-not (py -m pip show pyserial)) {
    py -m pip install pyserial
}


# PowerShellの設定ファイルをダウンロードして保存
# ホームディレクトリの .remodeling_pwsh.ps1 として保存
$remodelingPath = Join-Path $env:USERPROFILE ".remodeling_pwsh.ps1"
$remodelingUrl = "https://raw.githubusercontent.com/physics11688/miscellaneous/main/remodeling_pwsh.ps1"

try {
    Invoke-WebRequest -Uri $remodelingUrl -OutFile $remodelingPath -UseBasicParsing
}
catch {
    Write-Warning "設定ファイルのダウンロードに失敗しました: $_"
}



$includeBlock = @'
$remodelingScript = Join-Path $env:USERPROFILE ".remodeling_pwsh.ps1"
if (Test-Path $remodelingScript) {
    . $remodelingScript
}
'@

# $profile が存在しない場合は作成
if (-not (Test-Path $profile)) {
    New-Item -ItemType File -Path $profile -Force | Out-Null
}

# すでに同様の記述があるか確認（簡易的に .remodeling_pwsh.ps1 を含む行を探す）
if (-not (Select-String -Path $profile -Pattern '\.remodeling_pwsh\.ps1' -Quiet)) {
    Add-Content -Path $profile -Value $includeBlock
}


# 設定の反映 (ターミナルを再起動してもいいけど)
. $profile
