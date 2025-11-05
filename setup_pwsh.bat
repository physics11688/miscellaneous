@echo off
chcp 65001 >nul

echo PowerShell 7 (pwsh) の存在を確認しています...
where pwsh >nul 2>nul
if %errorlevel% neq 0 (
    echo PowerShell 7 が見つかりません。winget でインストールを試みます...

    where winget >nul 2>nul
    if %errorlevel% neq 0 (
        echo winget が見つかりません。手動で PowerShell 7 をインストールしてください。
        pause
        exit /b
    )

    echo PowerShell 7 をインストール中です...
    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

    echo インストールが完了したら Enter キーを押してください。
    pause
)

echo PowerShell 7 が見つかりました。実行ポリシーを RemoteSigned に設定します...
pwsh -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo 設定が完了しました。現在のポリシーを確認します...
pwsh -Command "Get-ExecutionPolicy -Scope CurrentUser"
echo ============================================
echo 上記が RemoteSigned なら成功です。
echo ============================================

echo PowerShell スクリプトをダウンロードして実行します...
pwsh -Command "iex (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_pwsh.ps1').Content"
pause
