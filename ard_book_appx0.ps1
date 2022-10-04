


############ 自動追記 ##############
# lsの色付け
Import-Module Get-ChildItemColor


# 2021/12/14追記. だめです. ターミナルから文字を拾うコードで難が出ます.
# PowerShell Core7でもConsoleのデフォルトエンコーディングはsjisなので必要
# https://www.vwnet.jp/Windows/PowerShell/CharCode.htm
#[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
#[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# git logなどのマルチバイト文字を表示させるため (絵文字含む)
#$env:LESSCHARSET = "utf-8"

# printpathでPATHの表示
function PrintPath {
   ($Env:Path).Split(";")
}

# ls -latと同じ
function CustomListChildItems () {
    Get-ChildItem $args[0] -force | Sort-Object -Property @{ Expression = 'LastWriteTime'; Descending = $true }, @{ Expression = 'Name'; Ascending = $true } | Format-Table -AutoSize -Property Mode, Length, LastWriteTime, Name 
}
# aliasの設定
Set-Alias ll CustomListChildItems



# sudo
function CustomSudo () {
    Start-Process wt -ArgumentList "-p PowerShell" -Verb runas
}
Set-Alias sudo CustomSudo
  
function CustomHosts () {
    Start-Process code C:\Windows\System32\drivers\etc\hosts -verb runas
}
Set-Alias hosts CustomHosts
 
function CustomUpdate () {
    explorer ms-settings:windowsupdate
}
Set-Alias update CustomUpdate
 
function UpdateAllpip () {
    pip freeze | ForEach-Object { $_.split('==')[0] } | ForEach-Object { pip install --upgrade $_ }
}
Set-Alias pipupdate UpdateAllpip

function gitpush ($Arg) {
    git add .
    git commit -m $Arg
    git push
   
}


# git status表示のため
Import-Module posh-git

# oh-my6-posh好みじゃない
# Import-Module oh-my-posh
#Set-Theme Paradox



# プロンプトの変更
# 色とかを変更したいときは -> https://qiita.com/Kosen-amai/items/134987a9edc6fe3f547c
function prompt () {
    $(Write-Host -NoNewline "`r`n" -ForegroundColor White) `
        + $(Write-Host -NoNewline "[" -ForegroundColor White) `
        + $(Write-Host -NoNewline $($env:USERNAME) -ForegroundColor Cyan) `
        + $(Write-Host -NoNewline "@" -ForegroundColor White) `
        + $(Write-Host -NoNewline $(get-location) -ForegroundColor DarkGreen) `
        + $(Write-Host -NoNewline "]" -ForegroundColor White) `
        + $(Write-VcsStatus) `
        + "`r`n> " 
}


#Set-Alias rm "$HOME\local\bin\trash.exe"
#Set-Alias m "C:\Users\tyama\local\bin\micro-2.0.10\micro.exe"
#Set-Alias micro "C:\Users\tyama\local\bin\micro-2.0.10\micro.exe"
#Set-Alias touch "$HOME\local\bin\touch.exe"
Set-Alias grep Select-String

# 絶対必要. 
Import-Module PSReadLine

# 色の設定
$colors = @{
    # ConsoleColor enum has all the old colors
    "Error"     = [ConsoleColor]::DarkRed

    # A mustardy 24 bit color escape sequence
    "String"    = "$([char]0x1b)[38;5;100m"

    # A light slate blue RGB value
    "Command"   = "#E06253"

    "Parameter" = "#e7eaec"
}

# 色の設定
Set-PSReadLineOption -Colors $colors

# 入力
# Historyから候補
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# listveiw素晴らしい
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -BellStyle None
Set-PSReadlineOption -HistoryNoDuplicates

# bash風のキーバインド
# Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -Colors @{ InlinePrediction = '#9CA3AF' }

# Ctrl + D で終了
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# Ctrl + ← → で単語移動 (単語の削除はCtrl + W or ↑)
Set-PSReadlineKeyHandler -Key Ctrl+LeftArrow -Function ShellBackwardWord
Set-PSReadlineKeyHandler -Key ctrl+rightArrow -Function ShellForwardWord
Set-PSReadlineKeyHandler -Key ctrl+upArrow -Function UnixWordRubout
Set-PSReadlineKeyHandler -Key ctrl+downArrow -Function Yank


$env:path += ";$env:ProgramFiles\LLVM\bin"   # clangのPATHをprofileで追加しとく.アップデートのたびに消えるし.


# C環境のアップデート. 管理者権限のときだけ使える。
function updateC () {
    # LLVMのアップデート
    winget upgrade LLVM.LLVM
      
    # MinGWのダウンロードURLを取得して 変数URL にセット 
    $URL = curl -s https://api.github.com/repos/niXman/mingw-builds-binaries/releases/latest | Select-String -Pattern "https.*x86.*win32-seh.*7z" | ForEach-Object { $_.Matches.Value }

    if ($null -eq $URL) {
        Write-Output "`nMingWのダウンロードURL取得に失敗しました`n後で再度試してみてください."
        exit
    }

    $version = $(C:\Program` Files\mingw64\bin\gcc.exe -dumpversion)
    if (Test-Path 'C:\Program Files\mingw64\bin') {
        if ($null -eq $version) {
            Write-Output "`ngccはインストール済みだけど,パスが通っていないので注意してください."
            Write-Output "このプログラム終了後に C:\Program Files\mingw64\bin にパスを通してください."
        }
    }
    else {
        Write-Output "`nC:\Program Files\mingw64\ が見当たりません.`n新規にインストールを行います."
    }


    if ( $URL -match $version) {
        Write-Output "`n現在使用中のMinGWは最新版です.`nアップデートを終了します."
    }
    else {
        # MinGWのダウンロード. 
        curl -OL "$URL"     # > ls .\x86*win32-seh*.7zでファイルを確認しておくといい

        # MinGWは特殊な形式で圧縮されてるので, 解凍用のソフトをダウンロード
        curl -OL https://www.7-zip.org/a/7zr.exe

        # 解凍
        .\7zr.exe x .\x86*win32-seh*.7z  # mingw64 ってフォルダが出来るはず

        # 後片付け
        Remove-Item -Recurse -Force .\7zr.exe, .\x86*win32-seh*.7z

        # フォルダの移動
        Move-Item -force .\mingw64 'C:\Program Files\'  # 同名ファイルがあっても強制移動

        $new_version = $(C:\Program` Files\mingw64\bin\gcc.exe -dumpversion)
        Write-Output "MinGWは $version から $new_version へアップデートされました."
    }

}


############ 自動追記 ##############