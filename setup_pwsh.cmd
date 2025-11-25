
@echo off
:: 必ず CRLF でアップロード（文字コードは UTF-8 推奨）
chcp 65001 >nul

setlocal

REM ====== 共通実行ファイルの変数定義 ======
set "WINGET_EXE=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"
set "PWSH_EXE=C:\Program Files\PowerShell\7\pwsh.exe"
set "PYMGR_EXE=C:\Program Files\PyManager\py.exe"

REM ====== winget の検出（既定→PATH検索） ======
if not exist "%WINGET_EXE%" (
    for /f "delims=" %%I in ('where winget 2^>nul') do set "WINGET_EXE=%%~fI"
)
if not exist "%WINGET_EXE%" (
    echo [ERROR] winget が見つかりません。Microsoft Store から「App Installer」をインストールしてください。
    pause
    exit /b 1
)

REM ====== Python Install Manager のインストール ======
echo [INFO] Python Install Manager をインストールします...
"%WINGET_EXE%" install --id Python.PythonInstallManager --source winget --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo [WARN] Python Install Manager のインストールに失敗した可能性があります（続行）。
)

REM ====== PyManager の設定（Windows PowerShell 5.1 経由） ======
if exist "%PYMGR_EXE%" (
    echo [INFO] PyManager を検出しました: "%PYMGR_EXE%"
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass ^
      -Command "& '%PYMGR_EXE%' install --configure"
    if errorlevel 1 (
        echo [WARN] PyManager の初期設定に失敗した可能性があります（続行）。
    )
) else (
    echo [ERROR] PyManager が見つかりませんでした: "%PYMGR_EXE%"
    echo         インストールが成功していないか、インストール先が異なる可能性があります。
    pause
    exit /b 1
)

REM ====== PowerShell 7 (pwsh) の存在確認・インストール ======
echo [INFO] PowerShell 7 (pwsh) の存在を確認しています...
if not exist "%PWSH_EXE%" (
    echo [INFO] PowerShell 7 が見つかりません。winget でインストールします...
    "%WINGET_EXE%" install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [ERROR] PowerShell 7 のインストールに失敗しました。手動でインストールしてください。
        pause
        exit /b 1
    )
) else (
    echo [INFO] PowerShell 7 が見つかりました: "%PWSH_EXE%"
)

REM ====== 任意：uutils.coreutils のインストール ======
"%WINGET_EXE%" install --id uutils.coreutils --source winget --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo [WARN] uutils.coreutils のインストールに失敗（続行）。
)

REM ====== 実行ポリシー設定（CurrentUser のみ） ======
echo [INFO] 実行ポリシーを RemoteSigned に設定します...
"%PWSH_EXE%" -NoLogo -NoProfile -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo [INFO] 現在のポリシーを確認します...
"%PWSH_EXE%" -NoLogo -NoProfile -Command "Get-ExecutionPolicy -Scope CurrentUser"
echo ============================================
echo 上記が RemoteSigned なら成功です。
echo ============================================


REM ====== Windows Terminal 初回起動（settings.json 生成のため）※必須処理 ======
start "" wt powershell -Command "exit"


REM ====== Windows Terminal の設定（Python スクリプト） ======
echo [INFO] Windows Terminal の設定を行います...

set "PY_EXE=%PYMGR_EXE%"
if not exist "%PY_EXE%" (
    echo [ERROR] PyManager の Python 実行ファイルが見つかりません: "%PY_EXE%"
    pause
    exit /b 1
)

set "PY_URL=https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_WinTerminal.py"
set "TEMP_PY=%TEMP%\temp_script.py"

echo [INFO] ダウンロード中: %PY_URL%
curl -s "%PY_URL%" -o "%TEMP_PY%"
if errorlevel 1 (
    echo [ERROR] ダウンロードに失敗しました。
    pause
    exit /b 1
)
for %%A in ("%TEMP_PY%") do if %%~zA==0 (
    echo [ERROR] ダウンロードしたファイルが 0 バイトです。
    type "%TEMP_PY%"
    pause
    exit /b 1
)

echo [INFO] Python スクリプトを実行します...
"%PY_EXE%" "%TEMP_PY%"
if errorlevel 1 (
    echo [WARN] 直実行に失敗。-c で再試行します...
    "%PY_EXE%" -c "exec(open(r'%TEMP_PY%','r',encoding='utf-8').read())"
    if errorlevel 1 (
        echo [ERROR] Python スクリプトの実行に失敗しました。
        del "%TEMP_PY%" >nul 2>&1
        pause
        exit /b 1
    )
)

del "%TEMP_PY%" >nul 2>&1
echo [INFO] Python スクリプト完了。

REM ====== PowerShell スクリプトをダウンロードして実行 ======
echo [INFO] PowerShell スクリプトをダウンロードして実行します...
"%PWSH_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
    "Invoke-WebRequest 'https://raw.githubusercontent.com/physics11688/miscellaneous/main/setup_pwsh.ps1' | Invoke-Expression"

echo [DONE] 全処理が完了しました。
pause
endlocal
