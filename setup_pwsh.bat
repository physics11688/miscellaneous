@echo off
chcp 65001 >nul

echo PowerShell 7 (pwsh) の存在を確認しています...

where.exe pwsh >nul 2>nul
if %errorlevel% neq 0 (
    echo PowerShell 7 が見つかりません。winget でインストールを試みます...

    "%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe" --version >nul 2>nul
    if errorlevel 1 (
        echo winget が見つかりません。手動で PowerShell 7 をインストールしてください。

        pause
        exit /b
        ) else (
        echo wingetが見つかりました。

    )


    echo PowerShell 7 をインストール中です...
    "C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps\winget.exe" install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

    start "" wt powershell -Command "exit"

)

"C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps\winget.exe" install uutils.coreutils
echo PowerShell 7 が見つかりました。実行ポリシーを RemoteSigned に設定します...
"C:\Program Files\PowerShell\7\pwsh.exe" -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo 設定が完了しました。現在のポリシーを確認します...
"C:\Program Files\PowerShell\7\pwsh.exe" -Command "Get-ExecutionPolicy -Scope CurrentUser"
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
py "%TEMP_PY%"

:: 一時ファイルを削除
del "%TEMP_PY%"

endlocal


echo PowerShell スクリプトをダウンロードして実行します...
"C:\Program Files\PowerShell\7\pwsh.exe" -Command "iex (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_pwsh.ps1').Content"
pause
