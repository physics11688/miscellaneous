@echo off
chcp 65001 >nul
setx PATH "%PATH%;C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps"
echo PowerShell 7 (pwsh) の存在を確認しています...

set "PATH=%PATH%;C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps"
where.exe pwsh >nul 2>nul
if %errorlevel% neq 0 (
    echo PowerShell 7 が見つかりません。winget でインストールを試みます...

    where winget >nul 2>nul
    if errorlevel 1 (
        echo winget が見つかりません。手動で PowerShell 7 をインストールしてください。

        pause
        exit /b
        ) else (
        echo wingetが見つかりました。
    )


    echo PowerShell 7 をインストール中です...
    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

)

set "PATH=%PATH%;C:\Program Files\PowerShell\7"
echo PowerShell 7 が見つかりました。実行ポリシーを RemoteSigned に設定します...
pwsh -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo 設定が完了しました。現在のポリシーを確認します...
pwsh -Command "Get-ExecutionPolicy -Scope CurrentUser"
echo ============================================
echo 上記が RemoteSigned なら成功です。
echo ============================================

echo Windows Terminalの設定を行います。

setlocal

:: GitHub の raw URL を指定
set "PY_URL=https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_WinTerminal.py"

:: 一時ファイル名を指定
set "TEMP_PY=%TEMP%\temp_script.py"

:: スクリプトをダウンロード
curl -s %PY_URL% -o "%TEMP_PY%"

:: Python スクリプトを実行
python "%TEMP_PY%"

:: 一時ファイルを削除
del "%TEMP_PY%"

endlocal


echo PowerShell スクリプトをダウンロードして実行します...
pwsh -Command "iex (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_pwsh.ps1').Content"
pause
