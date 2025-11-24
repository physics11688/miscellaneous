
# 1/5 PowerShellGet のインストール
if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
    Install-Module -Name PowerShellGet -Force -Scope CurrentUser
}

# 2/5 PSReadLine のインストール
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module PSReadLine -Force -Scope CurrentUser
}

# 3/5 Git のインストール
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git --source winget
}

# 4/5 posh-git のインストール
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    PowerShellGet\Install-Module posh-git -Force -Scope CurrentUser
}

$py = 'C:\Program Files\PyManager\py.exe'

& $py -m pip show pyserial *> $null

# 5/5 pyserial のインストール
if ($LASTEXITCODE -ne 0) {
    Write-Host "[INFO] pyserial が未インストールです。インストールします..."
    & $py -m pip install pyserial
}
else {
    Write-Host "[INFO] pyserial は既にインストールされています。"
}



# PowerShell の設定ファイルをダウンロード
$remodelingPath = Join-Path $env:USERPROFILE ".remodeling_pwsh.ps1"
$remodelingUrl = "https://raw.githubusercontent.com/physics11688/miscellaneous/main/remodeling_pwsh.ps1"

if (Test-Path $remodelingPath) {
    $overwrite = Read-Host "$remodelingPath がすでに存在します。上書きしますか？ (y/n)"
    if ($overwrite -notin @("y", "Y", "yes", "Yes")) {
        Write-Host "[INFO] 既存の .remodeling_pwsh.ps1 を保持しました。"
    }
    else {
        try {
            Invoke-WebRequest -Uri $remodelingUrl -OutFile $remodelingPath -UseBasicParsing
            Write-Host "[INFO] .remodeling_pwsh.ps1 を上書きしました。"
        }
        catch {
            Write-Warning "[ERROR] 設定ファイルのダウンロードに失敗しました: $_"
        }
    }
}
else {
    try {
        Invoke-WebRequest -Uri $remodelingUrl -OutFile $remodelingPath -UseBasicParsing
        Write-Host "[INFO] PowerShellの設定ファイルを保存しました。"
    }
    catch {
        Write-Warning "[ERROR] PowerShellの設定ファイルのダウンロードに失敗しました: $_"
    }
}

# $profile に安全な読み込みコードを追加
$includeBlock = @'
$remodelingScript = Join-Path $env:USERPROFILE ".remodeling_pwsh.ps1"
if (Test-Path $remodelingScript) {
    . $remodelingScript
}
'@

if (-not (Test-Path $profile)) {
    New-Item -ItemType File -Path $profile -Force | Out-Null
}

if (-not (Select-String -Path $profile -Pattern '\.remodeling_pwsh\.ps1' -Quiet)) {
    Add-Content -Path $profile -Value $includeBlock
}



# 設定の反映 (ターミナルを再起動してもいいけど)
# . $profile

Write-Output "[INFO] 初期設定が完了しました"
