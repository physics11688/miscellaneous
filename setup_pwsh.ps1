# 1/5 PowerShellGetはまあ, wingetみたいなやつのPowerShell機能限定版だと思えばいい
Install-Module -Name PowerShellGet -Force -Scope CurrentUser # 多分もう入ってる

# 2/5 コマンドとかを補完しまくりになる
Install-Module PSReadLine -AllowPrerelease -Force  -Scope CurrentUser

# 3/5 gitのインストール
winget install Git.Git   # 入ってなかったら

# 4/5 posh-git
PowerShellGet\Install-Module posh-git -Force -Scope CurrentUser

# 5/5 pyserial
py -m pip install pyserial


# PowerShellの設定ファイルをダウンロードして保存
# ホームディレクトリの .remodeling_pwsh.ps1 として保存
curl.exe -o "$env:USERPROFILE\.remodeling_pwsh.ps1" "https://raw.githubusercontent.com/physics11688/miscellaneous/main/remodeling_pwsh.ps1"

# PowerShellの設定ファイルに ↑ のファイルを読み込むよう追記
$includeLine = '. $env:USERPROFILE\.remodeling_pwsh.ps1'

# プロファイルファイルが存在しない場合は作成
if (-not (Test-Path $profile)) {
    New-Item -ItemType File -Path $profile -Force | Out-Null
}

# 内容を取得して、記述がなければ追記
if (-not (Get-Content $profile | Where-Object { $_ -eq $includeLine })) {
    Write-Output '. $env:USERPROFILE\.remodeling_pwsh.ps1' >> $profile
}




# 設定の反映 (ターミナルを再起動してもいいけど)
. $profile
