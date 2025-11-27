# lsの色付け
# Import-Module Get-ChildItemColor


# 2021/12/14追記. だめです. ターミナルから文字を拾うコードで難が出ます.
# PowerShell Core7でもConsoleのデフォルトエンコーディングはsjisなので必要
# https://www.vwnet.jp/Windows/PowerShell/CharCode.htm
#[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
#[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# git logなどのマルチバイト文字を表示させるため (絵文字含む)
#$env:LESSCHARSET = "utf-8"

# 管理者権限の確認
function isAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# printpathでPATHの表示
function PrintPath {
    param(
        [string]$Filter
    )

    $paths = (Get-ItemProperty -Path "HKCU:\Environment" -Name Path).Path -split ";" | Where-Object { $_ -ne "" }

    if ($Filter) {
        $paths | Where-Object { $_ -match [regex]::Escape($Filter) } | ForEach-Object { "$_" }
    }
    else {
        $paths | ForEach-Object { "$_" }
    }
}


Set-Alias path PrintPath



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
    py -m pip list --outdated | Select-Object -Skip 2 | ForEach-Object { py -m pip install --upgrade ($_.Split()[0]) }
}
Set-Alias pipupdate UpdateAllpip


function gitpush ($Arg) {
    git add .
    git commit -m $Arg
    git push

}

# ポート確認
function showp() {
    py -c "import serial.tools.list_ports;[print(p) for p in reversed(list(serial.tools.list_ports.comports()))]"
}

# 環境変数PATHの追加: Add-ToUserPath -NewPath "your_path"
function Add-ToUserPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$NewPath
    )

    # 現在のユーザー環境変数 PATH を取得
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    # すでに含まれているか確認
    if ($currentPath -split ";" | Where-Object { $_ -eq $NewPath }) {
        Write-Host "既に PATH に含まれています: $NewPath"
    }
    else {
        # 永続的に追加
        $updatedPath = "$currentPath;$NewPath"
        [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")
        Write-Host "ユーザー環境変数 PATH に追加しました: $NewPath"
    }

    # 現在のセッションにも即時反映
    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $NewPath })) {
        $env:PATH += ";$NewPath"
        Write-Host "現在のセッションの PATH にも追加しました。"
    }
    else {
        Write-Host "現在のセッションの PATH にも既に含まれています。"
    }
}



# git status表示のため
Import-Module posh-git

# プロンプトの変更

function Get-PrettyPath {
    try { $path = (Get-Location).Path } catch { return (Get-Location).ToString() }
    $homePath = $ExecutionContext.SessionState.PSVariable.GetValue('HOME')
    if ([string]::IsNullOrWhiteSpace($homePath)) { $homePath = [Environment]::GetFolderPath('UserProfile') }
    if ($path.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rest = $path.Substring($homePath.Length)
        if ([string]::IsNullOrEmpty($rest)) { return "~" }
        if ($rest[0] -in '\', '/') { $rest = $rest.Substring(1) }
        return "~\" + $rest
    }
    return $path
}

function Get-ShortHostname {
    $hostRaw = $env:HOSTNAME
    if (-not $hostRaw) { $hostRaw = $env:COMPUTERNAME }
    if (-not $hostRaw) { $hostRaw = [System.Net.Dns]::GetHostName() }
    if (-not $hostRaw) { return "" }
    $hostShort = $hostRaw.Split('.')[0]
    $hostShort = $hostShort -replace '^(DESKTOP-|LAPTOP-|PC-|WORKSTATION-)', 'WIN-'
    return $hostShort.Trim()
}

function prompt {
    # --- 上段：Git（必要な最小情報のみ） ---
    Write-Host "`n" -NoNewline
    $getGit = Get-Command Get-GitStatus -ErrorAction SilentlyContinue
    if ($getGit) {
        $s = Get-GitStatus
        if ($s) {
            $mark = if ($s.HasUntrackedFiles -or $s.HasWorking) { "*" } else { "" }
            $ahead = if ($s.AheadBy) { " ↑$($s.AheadBy)" }  else { "" }
            $behind = if ($s.BehindBy) { " ↓$($s.BehindBy)" } else { "" }
            $line = "[{0}{1}{2}{3}]" -f $s.Branch, $mark, $ahead, $behind

            # 好みの色（マゼンタのままでOK。変えるならここ）
            Write-Host $line -ForegroundColor Magenta
            # 色干渉が気になる場合のみリセット（ほぼ不要）
            # Write-Host "$($PSStyle.Reset)" -NoNewline
        }
    }


    # --- 1行目：ユーザー@ホスト:パス ---
    Write-Host "[" -NoNewline -ForegroundColor White
    if (isAdmin) {
        Write-Host "root" -NoNewline -ForegroundColor Red
        Write-Host "%"    -NoNewline -ForegroundColor White
    }
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Cyan
    Write-Host "@" -NoNewline -ForegroundColor White
    Write-Host (Get-ShortHostname) -NoNewline -ForegroundColor Yellow
    Write-Host ":" -NoNewline -ForegroundColor White
    Write-Host (Get-PrettyPath) -NoNewline -ForegroundColor DarkGreen
    Write-Host "]" -NoNewline -ForegroundColor White
    Write-Host "`n" -NoNewline

    # --- プロンプト記号 ---
    if (isAdmin) {
        Write-Host "${PSStyle.Foreground.Red}>${PSStyle.Reset}" -NoNewline
    }
    else {
        $pink = $PSStyle.Foreground.FromRgb(255, 95, 135)
        Write-Host "${pink}>${PSStyle.Reset}" -NoNewline
    }

    return " "
}


#Set-Alias rm "$HOME\local\bin\trash.exe"
#Set-Alias m "C:\Users\tyama\local\bin\micro-2.0.10\micro.exe"
#Set-Alias micro "C:\Users\tyama\local\bin\micro-2.0.10\micro.exe"
#Set-Alias touch "$HOME\local\bin\touch.exe"
Set-Alias grep Select-String
# Set-Alias which where.exe
Set-Alias bk cd-

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

# Ctrl + ← / → ：単語単位で移動
Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow  -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+UpArrow  -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Ctrl+DownArrow -Function Yank

# Ctrl + Backspace ：前の単語を削除
Set-PSReadLineKeyHandler -Chord Ctrl+Backspace -Function BackwardKillWord

# Ctrl + Delete ：次の単語を削除
Set-PSReadLineKeyHandler -Chord Ctrl+Delete -Function KillWord

# Ctrl + U ：行頭まで削除
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardKillLine

# Ctrl + K ：行末まで削除
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function KillLine

# Ctrl + Y ：直前に削除した内容を貼り付け（yank）
Set-PSReadLineKeyHandler -Chord Ctrl+y -Function Yank

# Ctrl + L ：画面クリア
Set-PSReadLineKeyHandler -Chord Ctrl+l -Function ClearScreen

# Ctrl + R ：履歴検索（インクリメンタルサーチ）
Set-PSReadLineKeyHandler -Chord Ctrl+r -Function ReverseSearchHistory

# Alt + . ：直前のコマンドの最後の引数を挿入（bash互換）
Set-PSReadLineKeyHandler -Chord Alt+. -Function YankLastArg


$env:path += ";$env:ProgramFiles\LLVM\bin"    # clangのPATHをprofileで追加しとく.アップデートのたびに消えるし.
$env:path += ";$env:ProgramFiles\mingw64\bin" # 一応・・・

# C環境のアップデート.
function updateC {
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
        Write-Host "`n=== [INFO] LLVMのアップデート ==="
        winget upgrade --id LLVM.LLVM --accept-source-agreements --accept-package-agreements | Out-Host
    }
    catch {
        Write-Warning "[ERROR] LLVM のアップデートでエラーが発生しました: $_"
    }

    Add-ToUserPath -NewPath "C:\Program Files\LLVM\bin"

    Write-Host "`n=== [INFO] MinGW の最新版URL取得 ==="
    try {
        $URL = (curl.exe -s $githubApiUrl |
            Select-String -Pattern "https.*x86_64.*posix-seh-ucrt.*7z" |
            ForEach-Object { $_.Matches.Value } |
            Select-Object -First 1)

        if (-not $URL) {
            throw "[ERROR] GitHub APIからMinGWのURLを取得できませんでした。"
        }
        Write-Host "[ERROR] 取得URL: $URL"
    }
    catch {
        Write-Error $_
        return
    }

    # 既存バージョンチェック
    $currentVersion = if (Test-Path $gccPath) { & $gccPath -dumpversion } else { $null }

    if ($currentVersion -and ($URL -match [Regex]::Escape($currentVersion))) {
        Write-Host "`n[INFO] 現在のMinGW ($currentVersion) は最新版のためアップデート不要です。"
        return
    }

    if ($currentVersion) {
        Write-Host "`n[INFO] MinGW ($currentVersion) を最新版にアップデートします。"
    }
    else {
        Write-Host "`n[INFO] MinGWを新規インストールします。"
    }

    # 作業用フォルダ
    $tempDir = Join-Path $env:TEMP "mingw_update"
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Set-Location $tempDir

    # 7zr.exe の取得
    Write-Host "`n[INFO] 7-Zip展開ツールをダウンロード中..."
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile "7zr.exe"

    # MinGWダウンロード
    Write-Host "[INFO] MinGWをダウンロード中..."
    $archiveName = Split-Path $URL -Leaf
    Invoke-WebRequest -Uri $URL -OutFile $archiveName

    # 解凍
    Write-Host "[INFO] 解凍中..."
    & .\7zr.exe x $archiveName | Out-Null

    if (-not (Test-Path ".\mingw64")) {
        Write-Error "[ERROR] mingw64 フォルダが見つかりません。展開に失敗した可能性があります。"
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
        Write-Host "`n[INFO] MinGWは $currentVersion → $newVersion に更新されました。"
    }
    else {
        Write-Host "`n[INFO] MinGW $newVersion のインストールが完了しました。"
    }

    Write-Host "`nPATH: $mingwPath"
    Add-ToUserPath -NewPath "$mingwPath\bin"
}

# ================================
# uutils.coreutils + エイリアス削除
# ================================

# coreutilsがインストールされているか確認
if (Get-Command coreutils -ErrorAction SilentlyContinue) {

    # 日本語対応
    $env:LANG = "ja_JP.UTF-8"




    # 削除する既定エイリアス
    $aliasesToRemove = @(
        'arch', 'b2sum', 'base32', 'base64', 'basename', 'basenc', 'cat', 'cksum', 'comm', 'cp', 'csplit',
        'cut', 'date', 'dd', 'df', 'dir', 'dircolors', 'dirname', 'du', 'echo', 'env', 'expand', 'expr', 'factor',
        'false', 'fmt', 'fold', 'hashsum', 'head', 'hostname', 'join', 'link', 'ln', 'ls', 'md5sum', 'mkdir',
        'mktemp', 'more', 'mv', 'nl', 'nproc', 'numfmt', 'od', 'paste', 'pr', 'printenv', 'printf', 'ptx', 'pwd',
        'readlink', 'realpath', 'rmdir', 'seq', 'sha1sum', 'sha224sum', 'sha256sum', 'sha384sum',
        'sha512sum', 'shred', 'shuf', 'sleep', 'sort', 'split', 'sum', 'sync', 'tac', 'tail', 'tee', 'test',
        'touch', 'tr', 'true', 'truncate', 'tsort', 'uname', 'unexpand', 'uniq', 'unlink', 'vdir', 'wc',
        'whoami', 'yes', 'clear', 'kill', 'man', 'type'
    )
    foreach ($a in $aliasesToRemove) {
        Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue
    }

    # uutilsコマンド一覧
    $uutilsCommands = @(
        '[', 'arch', 'b2sum', 'base32', 'base64', 'basename', 'basenc', 'cat', 'cksum', 'comm', 'cp', 'csplit',
        'cut', 'date', 'dd', 'df', 'dir', 'dircolors', 'dirname', 'du', 'echo', 'env', 'expand', 'expr', 'factor',
        'false', 'fmt', 'fold', 'hashsum', 'head', 'hostname', 'join', 'link', 'ln', 'ls', 'md5sum', 'mkdir',
        'mktemp', 'more', 'mv', 'nl', 'nproc', 'numfmt', 'od', 'paste', 'pr', 'printenv', 'printf', 'ptx', 'pwd',
        'readlink', 'realpath', 'rm', 'rmdir', 'seq', 'sha1sum', 'sha224sum', 'sha256sum', 'sha384sum',
        'sha512sum', 'shred', 'shuf', 'sleep', 'sort', 'split', 'sum', 'sync', 'tac', 'tail', 'tee', 'test',
        'touch', 'tr', 'true', 'truncate', 'tsort', 'uname', 'unexpand', 'uniq', 'unlink', 'vdir', 'wc',
        'whoami', 'yes'
    )

    foreach ($cmd in $uutilsCommands) {
        $func = @"
Function $cmd {
    param([Parameter(ValueFromRemainingArguments=`$true)]`$args)
    & coreutils $cmd `$args
}
"@
        Invoke-Expression $func
    }



    # 特別設定：ls は色付き表示

    Function ls {
        param([Parameter(ValueFromRemainingArguments = $true)]$args)
        coreutils ls --color=auto @args
    }

    Function ll {
        param([Parameter(ValueFromRemainingArguments = $true)]$args)
        coreutils ls -la --color=auto @args
    }

    $env:LS_COLORS = "bd=38;5;68:ca=38;5;17:cd=38;5;113;1:di=38;5;30:do=38;5;127:ex=38;5;208;1:pi=38;5;126:fi=0:ln=target:mh=38;5;222;1:no=0:or=48;5;196;38;5;232;1:ow=38;5;220;1:sg=48;5;3;38;5;0:su=38;5;220;1;3;100;1:so=38;5;197:st=38;5;86;48;5;234:tw=48;5;235;38;5;139;3:*LS_COLORS=48;5;89;38;5;197;1;3;4;7:*README=38;5;220;1:*README.rst=38;5;220;1:*README.md=38;5;220;1:*LICENSE=38;5;220;1:*COPYING=38;5;220;1:*INSTALL=38;5;220;1:*COPYRIGHT=38;5;220;1:*AUTHORS=38;5;220;1:*HISTORY=38;5;220;1:*CONTRIBUTORS=38;5;220;1:*PATENTS=38;5;220;1:*VERSION=38;5;220;1:*NOTICE=38;5;220;1:*CHANGES=38;5;220;1:*.log=38;5;190:*.txt=38;5;253:*.adoc=38;5;184:*.asciidoc=38;5;184:*.etx=38;5;184:*.info=38;5;184:*.markdown=38;5;184:*.md=38;5;184:*.mkd=38;5;184:*.nfo=38;5;184:*.pod=38;5;184:*.rst=38;5;184:*.tex=38;5;184:*.textile=38;5;184:*.bib=38;5;178:*.json=38;5;178:*.jsonl=38;5;178:*.jsonnet=38;5;178:*.libsonnet=38;5;142:*.ndjson=38;5;178:*.msg=38;5;178:*.pgn=38;5;178:*.rss=38;5;178:*.xml=38;5;178:*.fxml=38;5;178:*.toml=38;5;178:*.yaml=38;5;178:*.yml=38;5;178:*.RData=38;5;178:*.rdata=38;5;178:*.xsd=38;5;178:*.dtd=38;5;178:*.sgml=38;5;178:*.rng=38;5;178:*.rnc=38;5;178:*.cbr=38;5;141:*.cbz=38;5;141:*.chm=38;5;141:*.djvu=38;5;141:*.pdf=38;5;141:*.PDF=38;5;141:*.mobi=38;5;141:*.epub=38;5;141:*.docm=38;5;111;4:*.doc=38;5;111:*.docx=38;5;111:*.odb=38;5;111:*.odt=38;5;111:*.rtf=38;5;111:*.odp=38;5;166:*.pps=38;5;166:*.ppt=38;5;166:*.pptx=38;5;166:*.ppts=38;5;166:*.pptxm=38;5;166;4:*.pptsm=38;5;166;4:*.csv=38;5;78:*.tsv=38;5;78:*.ods=38;5;112:*.xla=38;5;76:*.xls=38;5;112:*.xlsx=38;5;112:*.xlsxm=38;5;112;4:*.xltm=38;5;73;4:*.xltx=38;5;73:*.pages=38;5;111:*.numbers=38;5;112:*.key=38;5;166:*config=1:*cfg=1:*conf=1:*rc=1:*authorized_keys=1:*known_hosts=1:*.ini=1:*.plist=1:*.viminfo=1:*.pcf=1:*.psf=1:*.hidden-color-scheme=1:*.hidden-tmTheme=1:*.last-run=1:*.merged-ca-bundle=1:*.sublime-build=1:*.sublime-commands=1:*.sublime-keymap=1:*.sublime-settings=1:*.sublime-snippet=1:*.sublime-project=1:*.sublime-workspace=1:*.tmTheme=1:*.user-ca-bundle=1:*.epf=1:*.git=38;5;197:*.gitignore=38;5;240:*.gitattributes=38;5;240:*.gitmodules=38;5;240:*.awk=38;5;172:*.bash=38;5;172:*.bat=38;5;172:*.BAT=38;5;172:*.sed=38;5;172:*.sh=38;5;172:*.zsh=38;5;172:*.vim=38;5;172:*.kak=38;5;172:*.ahk=38;5;41:*.py=38;5;41:*.ipynb=38;5;41:*.rb=38;5;41:*.gemspec=38;5;41:*.pl=38;5;208:*.PL=38;5;160:*.t=38;5;114:*.msql=38;5;222:*.mysql=38;5;222:*.pgsql=38;5;222:*.sql=38;5;222:*.tcl=38;5;64;1:*.r=38;5;49:*.R=38;5;49:*.gs=38;5;81:*.clj=38;5;41:*.cljs=38;5;41:*.cljc=38;5;41:*.cljw=38;5;41:*.scala=38;5;41:*.sc=38;5;41:*.dart=38;5;51:*.asm=38;5;81:*.cl=38;5;81:*.lisp=38;5;81:*.rkt=38;5;81:*.lua=38;5;81:*.moon=38;5;81:*.c=38;5;81:*.C=38;5;81:*.h=38;5;110:*.H=38;5;110:*.tcc=38;5;110:*.c++=38;5;81:*.h++=38;5;110:*.hpp=38;5;110:*.hxx=38;5;110:*.ii=38;5;110:*.M=38;5;110:*.m=38;5;110:*.cc=38;5;81:*.cs=38;5;81:*.cp=38;5;81:*.cpp=38;5;81:*.cxx=38;5;81:*.cr=38;5;81:*.go=38;5;81:*.f=38;5;81:*.F=38;5;81:*.for=38;5;81:*.ftn=38;5;81:*.f90=38;5;81:*.F90=38;5;81:*.f95=38;5;81:*.F95=38;5;81:*.f03=38;5;81:*.F03=38;5;81:*.f08=38;5;81:*.F08=38;5;81:*.nim=38;5;81:*.nimble=38;5;81:*.s=38;5;110:*.S=38;5;110:*.rs=38;5;81:*.scpt=38;5;219:*.swift=38;5;219:*.sx=38;5;81:*.vala=38;5;81:*.vapi=38;5;81:*.hi=38;5;110:*.hs=38;5;81:*.lhs=38;5;81:*.agda=38;5;81:*.lagda=38;5;81:*.lagda.tex=38;5;81:*.lagda.rst=38;5;81:*.lagda.md=38;5;81:*.agdai=38;5;110:*.zig=38;5;81:*.v=38;5;81:*.pyc=38;5;240:*.tf=38;5;168:*.tfstate=38;5;168:*.tfvars=38;5;168:*.css=38;5;125;1:*.less=38;5;125;1:*.sass=38;5;125;1:*.scss=38;5;125;1:*.htm=38;5;125;1:*.html=38;5;125;1:*.jhtm=38;5;125;1:*.mht=38;5;125;1:*.eml=38;5;125;1:*.mustache=38;5;125;1:*.coffee=38;5;074;1:*.java=38;5;074;1:*.js=38;5;074;1:*.mjs=38;5;074;1:*.jsm=38;5;074;1:*.jsp=38;5;074;1:*.php=38;5;81:*.ctp=38;5;81:*.twig=38;5;81:*.vb=38;5;81:*.vba=38;5;81:*.vbs=38;5;81:*Dockerfile=38;5;155:*.dockerignore=38;5;240:*Makefile=38;5;155:*MANIFEST=38;5;243:*pm_to_blib=38;5;240:*.nix=38;5;155:*.dhall=38;5;178:*.rake=38;5;155:*.am=38;5;242:*.in=38;5;242:*.hin=38;5;242:*.scan=38;5;242:*.m4=38;5;242:*.old=38;5;242:*.out=38;5;242:*.SKIP=38;5;244:*.diff=48;5;197;38;5;232:*.patch=48;5;197;38;5;232;1:*.bmp=38;5;97:*.dicom=38;5;97:*.tiff=38;5;97:*.tif=38;5;97:*.TIFF=38;5;97:*.cdr=38;5;97:*.flif=38;5;97:*.gif=38;5;97:*.icns=38;5;97:*.ico=38;5;97:*.jpeg=38;5;97:*.JPG=38;5;97:*.jpg=38;5;97:*.nth=38;5;97:*.png=38;5;97:*.psd=38;5;97:*.pxd=38;5;97:*.pxm=38;5;97:*.xpm=38;5;97:*.webp=38;5;97:*.ai=38;5;99:*.eps=38;5;99:*.epsf=38;5;99:*.drw=38;5;99:*.ps=38;5;99:*.svg=38;5;99:*.avi=38;5;114:*.divx=38;5;114:*.IFO=38;5;114:*.m2v=38;5;114:*.m4v=38;5;114:*.mkv=38;5;114:*.MOV=38;5;114:*.mov=38;5;114:*.mp4=38;5;114:*.mpeg=38;5;114:*.mpg=38;5;114:*.ogm=38;5;114:*.rmvb=38;5;114:*.sample=38;5;114:*.wmv=38;5;114:*.3g2=38;5;115:*.3gp=38;5;115:*.gp3=38;5;115:*.webm=38;5;115:*.gp4=38;5;115:*.asf=38;5;115:*.flv=38;5;115:*.ts=38;5;115:*.ogv=38;5;115:*.f4v=38;5;115:*.VOB=38;5;115;1:*.vob=38;5;115;1:*.ass=38;5;117:*.srt=38;5;117:*.ssa=38;5;117:*.sub=38;5;117:*.sup=38;5;117:*.vtt=38;5;117:*.3ga=38;5;137;1:*.S3M=38;5;137;1:*.aac=38;5;137;1:*.amr=38;5;137;1:*.au=38;5;137;1:*.caf=38;5;137;1:*.dat=38;5;137;1:*.dts=38;5;137;1:*.fcm=38;5;137;1:*.m4a=38;5;137;1:*.mod=38;5;137;1:*.mp3=38;5;137;1:*.mp4a=38;5;137;1:*.oga=38;5;137;1:*.ogg=38;5;137;1:*.opus=38;5;137;1:*.s3m=38;5;137;1:*.sid=38;5;137;1:*.wma=38;5;137;1:*.ape=38;5;136;1:*.aiff=38;5;136;1:*.cda=38;5;136;1:*.flac=38;5;136;1:*.alac=38;5;136;1:*.mid=38;5;136;1:*.midi=38;5;136;1:*.pcm=38;5;136;1:*.wav=38;5;136;1:*.wv=38;5;136;1:*.wvc=38;5;136;1:*.afm=38;5;66:*.fon=38;5;66:*.fnt=38;5;66:*.pfb=38;5;66:*.pfm=38;5;66:*.ttf=38;5;66:*.otf=38;5;66:*.woff=38;5;66:*.woff2=38;5;66:*.PFA=38;5;66:*.pfa=38;5;66:*.7z=38;5;40:*.a=38;5;40:*.arj=38;5;40:*.bz2=38;5;40:*.cpio=38;5;40:*.gz=38;5;40:*.lrz=38;5;40:*.lz=38;5;40:*.lzma=38;5;40:*.lzo=38;5;40:*.rar=38;5;40:*.s7z=38;5;40:*.sz=38;5;40:*.tar=38;5;40:*.tgz=38;5;40:*.warc=38;5;40:*.WARC=38;5;40:*.xz=38;5;40:*.z=38;5;40:*.zip=38;5;40:*.zipx=38;5;40:*.zoo=38;5;40:*.zpaq=38;5;40:*.zst=38;5;40:*.zstd=38;5;40:*.zz=38;5;40:*.apk=38;5;215:*.ipa=38;5;215:*.deb=38;5;215:*.rpm=38;5;215:*.jad=38;5;215:*.jar=38;5;215:*.cab=38;5;215:*.pak=38;5;215:*.pk3=38;5;215:*.vdf=38;5;215:*.vpk=38;5;215:*.bsp=38;5;215:*.dmg=38;5;215:*.r[0-9]{0,2}=38;5;239:*.zx[0-9]{0,2}=38;5;239:*.z[0-9]{0,2}=38;5;239:*.part=38;5;239:*.iso=38;5;124:*.bin=38;5;124:*.nrg=38;5;124:*.qcow=38;5;124:*.sparseimage=38;5;124:*.toast=38;5;124:*.vcd=38;5;124:*.vmdk=38;5;124:*.accdb=38;5;60:*.accde=38;5;60:*.accdr=38;5;60:*.accdt=38;5;60:*.db=38;5;60:*.fmp12=38;5;60:*.fp7=38;5;60:*.localstorage=38;5;60:*.mdb=38;5;60:*.mde=38;5;60:*.sqlite=38;5;60:*.typelib=38;5;60:*.nc=38;5;60:*.pacnew=38;5;33:*.un~=38;5;241:*.orig=38;5;241:*.BUP=38;5;241:*.bak=38;5;241:*.o=38;5;241:*core=38;5;241:*.mdump=38;5;241:*.rlib=38;5;241:*.dll=38;5;241:*.swp=38;5;244:*.swo=38;5;244:*.tmp=38;5;244:*.sassc=38;5;244:*.pid=38;5;248:*.state=38;5;248:*lockfile=38;5;248:*lock=38;5;248:*.err=38;5;160;1:*.error=38;5;160;1:*.stderr=38;5;160;1:*.aria2=38;5;241:*.dump=38;5;241:*.stackdump=38;5;241:*.zcompdump=38;5;241:*.zwc=38;5;241:*.pcap=38;5;29:*.cap=38;5;29:*.dmp=38;5;29:*.DS_Store=38;5;239:*.localized=38;5;239:*.CFUserTextEncoding=38;5;239:*.allow=38;5;112:*.deny=38;5;196:*.service=38;5;45:*@.service=38;5;45:*.socket=38;5;45:*.swap=38;5;45:*.device=38;5;45:*.mount=38;5;45:*.automount=38;5;45:*.target=38;5;45:*.path=38;5;45:*.timer=38;5;45:*.snapshot=38;5;45:*.application=38;5;116:*.cue=38;5;116:*.description=38;5;116:*.directory=38;5;116:*.m3u=38;5;116:*.m3u8=38;5;116:*.md5=38;5;116:*.properties=38;5;116:*.sfv=38;5;116:*.theme=38;5;116:*.torrent=38;5;116:*.urlview=38;5;116:*.webloc=38;5;116:*.lnk=38;5;39:*CodeResources=38;5;239:*PkgInfo=38;5;239:*.nib=38;5;57:*.car=38;5;57:*.dylib=38;5;241:*.entitlements=1:*.pbxproj=1:*.strings=1:*.storyboard=38;5;196:*.xcconfig=1:*.xcsettings=1:*.xcuserstate=1:*.xcworkspacedata=1:*.xib=38;5;208:*.asc=38;5;192;3:*.bfe=38;5;192;3:*.enc=38;5;192;3:*.gpg=38;5;192;3:*.signature=38;5;192;3:*.sig=38;5;192;3:*.p12=38;5;192;3:*.pem=38;5;192;3:*.pgp=38;5;192;3:*.p7s=38;5;192;3:*id_dsa=38;5;192;3:*id_rsa=38;5;192;3:*id_ecdsa=38;5;192;3:*id_ed25519=38;5;192;3:*.32x=38;5;213:*.cdi=38;5;213:*.fm2=38;5;213:*.rom=38;5;213:*.sav=38;5;213:*.st=38;5;213:*.a00=38;5;213:*.a52=38;5;213:*.A64=38;5;213:*.a64=38;5;213:*.a78=38;5;213:*.adf=38;5;213:*.atr=38;5;213:*.gb=38;5;213:*.gba=38;5;213:*.gbc=38;5;213:*.gel=38;5;213:*.gg=38;5;213:*.ggl=38;5;213:*.ipk=38;5;213:*.j64=38;5;213:*.nds=38;5;213:*.nes=38;5;213:*.sms=38;5;213:*.8xp=38;5;121:*.8eu=38;5;121:*.82p=38;5;121:*.83p=38;5;121:*.8xe=38;5;121:*.stl=38;5;216:*.dwg=38;5;216:*.ply=38;5;216:*.wrl=38;5;216:*.pot=38;5;7:*.pcb=38;5;7:*.mm=38;5;7:*.gbr=38;5;7:*.scm=38;5;7:*.xcf=38;5;7:*.spl=38;5;7:*.Rproj=38;5;11:*.sis=38;5;7:*.1p=38;5;7:*.3p=38;5;7:*.cnc=38;5;7:*.def=38;5;7:*.ex=38;5;7:*.example=38;5;7:*.feature=38;5;7:*.ger=38;5;7:*.ics=38;5;7:*.map=38;5;7:*.mf=38;5;7:*.mfasl=38;5;7:*.mi=38;5;7:*.mtx=38;5;7:*.pc=38;5;7:*.pi=38;5;7:*.plt=38;5;7:*.pm=38;5;7:*.rdf=38;5;7:*.ru=38;5;7:*.sch=38;5;7:*.sty=38;5;7:*.sug=38;5;7:*.tdy=38;5;7:*.tfm=38;5;7:*.tfnt=38;5;7:*.tg=38;5;7:*.vcard=38;5;7:*.vcf=38;5;7:*.xln=38;5;7:*.iml=38;5;166:"
}

# ls(Get-ChildItem) の色付け
# http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors
# https://4sysops.com/archives/using-powershell-with-psstyle/
# pwshのprofile で読み込め →  . path\to\LC_CORLS.ps1
if ($PSVersionTable.PSVersion.ToString() -ge "7.3.0") {
    $PSStyle.FileInfo.Directory = "`e[38;5;30m" # ディレクトリは緑
    $PSStyle.FileInfo.Extension[".exe"] = "`e[38;5;205m"
    $PSStyle.FileInfo.Extension[".elf"] = "`e[38;5;205m"
    $PSStyle.FileInfo.Extension[".txt"] = "`e[38;5;253m"
    $PSStyle.FileInfo.Extension[".log"] = "`e[38;5;190m"
    $PSStyle.FileInfo.Extension[".adoc"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".asciidoc"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".etx"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".info"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".markdown"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".md"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".mkd"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".nfo"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".org"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".pod"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".rst"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".tex"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".textile"] = "`e[38;5;184m"
    $PSStyle.FileInfo.Extension[".bib"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".json"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".jsonl"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".jsonnet"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".libsonnet"] = "`e[38;5;142m"
    $PSStyle.FileInfo.Extension[".ndjson"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".msg"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".pgn"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".rss"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".xml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".fxml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".toml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".yaml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".yml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".RData"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".rdata"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".xsd"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".dtd"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".sgml"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".rng"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".rnc"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".accdb"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".accde"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".accdr"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".accdt"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".db"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".fmp12"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".fp7"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".localstorage"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".mdb"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".mde"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".sqlite"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".typelib"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".nc"] = "`e[38;5;60m"
    $PSStyle.FileInfo.Extension[".cbr"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".cbz"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".chm"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".djvu"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".pdf"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".PDF"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".mobi"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".epub"] = "`e[38;5;141m"
    $PSStyle.FileInfo.Extension[".docm"] = "`e[38;5;111;4m"
    $PSStyle.FileInfo.Extension[".doc"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".docx"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".odb"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".odt"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".rtf"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".pages"] = "`e[38;5;111m"
    $PSStyle.FileInfo.Extension[".odp"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".pps"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".ppt"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".pptx"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".ppts"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".pptxm"] = "`e[38;5;166;4m"
    $PSStyle.FileInfo.Extension[".pptsm"] = "`e[38;5;166;4m"
    $PSStyle.FileInfo.Extension[".csv"] = "`e[38;5;78m"
    $PSStyle.FileInfo.Extension[".tsv"] = "`e[38;5;78m"
    $PSStyle.FileInfo.Extension[".numbers"] = "`e[38;5;112m"
    $PSStyle.FileInfo.Extension[".ods"] = "`e[38;5;112m"
    $PSStyle.FileInfo.Extension[".xla"] = "`e[38;5;76m"
    $PSStyle.FileInfo.Extension[".xls"] = "`e[38;5;112m"
    $PSStyle.FileInfo.Extension[".xlsx"] = "`e[38;5;112m"
    $PSStyle.FileInfo.Extension[".xlsxm"] = "`e[38;5;112;4m"
    $PSStyle.FileInfo.Extension[".xltm"] = "`e[38;5;73;4m"
    $PSStyle.FileInfo.Extension[".xltx"] = "`e[38;5;73m"
    $PSStyle.FileInfo.Extension[".key"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".ini"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".plist"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".profile"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".bash_profile"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".bash_login"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".bash_logout"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".zshenv"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".zprofile"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".zlogin"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".zlogout"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".viminfo"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".pcf"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".psf"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".hidden-color-scheme"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".hidden-tmTheme"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".last-run"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".merged-ca-bundle"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-build"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-commands"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-keymap"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-settings"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-snippet"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-project"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".sublime-workspace"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".tmTheme"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".user-ca-bundle"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".rstheme"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".epf"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".git"] = "`e[38;5;197m"
    $PSStyle.FileInfo.Extension[".gitignore"] = "`e[38;5;240m"
    $PSStyle.FileInfo.Extension[".gitattributes"] = "`e[38;5;240m"
    $PSStyle.FileInfo.Extension[".gitmodules"] = "`e[38;5;240m"
    $PSStyle.FileInfo.Extension[".awk"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".bash"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".bat"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".BAT"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".sed"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".sh"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".zsh"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".vim"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".kak"] = "`e[38;5;172m"
    $PSStyle.FileInfo.Extension[".ahk"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".py"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".ipynb"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".xsh"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".rb"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".gemspec"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".pl"] = "`e[38;5;208m"
    $PSStyle.FileInfo.Extension[".PL"] = "`e[38;5;160m"
    $PSStyle.FileInfo.Extension[".pm"] = "`e[38;5;203m"
    $PSStyle.FileInfo.Extension[".t"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".msql"] = "`e[38;5;222m"
    $PSStyle.FileInfo.Extension[".mysql"] = "`e[38;5;222m"
    $PSStyle.FileInfo.Extension[".pgsql"] = "`e[38;5;222m"
    $PSStyle.FileInfo.Extension[".sql"] = "`e[38;5;222m"
    $PSStyle.FileInfo.Extension[".tcl"] = "`e[38;5;64;1m"
    $PSStyle.FileInfo.Extension[".r"] = "`e[38;5;49m"
    $PSStyle.FileInfo.Extension[".R"] = "`e[38;5;49m"
    $PSStyle.FileInfo.Extension[".gs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".clj"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".cljs"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".cljc"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".cljw"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".scala"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".sc"] = "`e[38;5;41m"
    $PSStyle.FileInfo.Extension[".dart"] = "`e[38;5;51m"
    $PSStyle.FileInfo.Extension[".asm"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cl"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lisp"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".rkt"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".el"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".elc"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".eln"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".lua"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".moon"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".c"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".C"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".h"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".H"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".tcc"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".c++"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".h++"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".hpp"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".hxx"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".ii"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".M"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".m"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".cc"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cp"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cpp"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cxx"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".cr"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".go"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".f"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".F"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".for"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".ftn"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".f90"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".F90"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".f95"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".F95"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".f03"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".F03"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".f08"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".F08"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".nim"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".nimble"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".s"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".S"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".rs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".scpt"] = "`e[38;5;219m"
    $PSStyle.FileInfo.Extension[".swift"] = "`e[38;5;219m"
    $PSStyle.FileInfo.Extension[".sx"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".vala"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".vapi"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".hi"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".hs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lhs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".agda"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lagda"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lagda.tex"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lagda.rst"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".lagda.md"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".agdai"] = "`e[38;5;110m"
    $PSStyle.FileInfo.Extension[".zig"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".v"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".pyc"] = "`e[38;5;240m"
    $PSStyle.FileInfo.Extension[".tf"] = "`e[38;5;168m"
    $PSStyle.FileInfo.Extension[".tfstate"] = "`e[38;5;168m"
    $PSStyle.FileInfo.Extension[".tfvars"] = "`e[38;5;168m"
    $PSStyle.FileInfo.Extension[".css"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".less"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".sass"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".scss"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".htm"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".html"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".jhtm"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".mht"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".eml"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".mustache"] = "`e[38;5;125;1m"
    $PSStyle.FileInfo.Extension[".coffee"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".java"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".js"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".mjs"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".jsm"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".jsp"] = "`e[38;5;074;1m"
    $PSStyle.FileInfo.Extension[".php"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".ctp"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".twig"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".vb"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".vba"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".vbs"] = "`e[38;5;81m"
    $PSStyle.FileInfo.Extension[".dockerignore"] = "`e[38;5;240m"
    $PSStyle.FileInfo.Extension[".nix"] = "`e[38;5;155m"
    $PSStyle.FileInfo.Extension[".dhall"] = "`e[38;5;178m"
    $PSStyle.FileInfo.Extension[".rake"] = "`e[38;5;155m"
    $PSStyle.FileInfo.Extension[".am"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".in"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".hin"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".scan"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".m4"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".old"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".out"] = "`e[38;5;242m"
    $PSStyle.FileInfo.Extension[".SKIP"] = "`e[38;5;244m"
    $PSStyle.FileInfo.Extension[".diff"] = "`e[48;5;197;38;5;232m"
    $PSStyle.FileInfo.Extension[".patch"] = "`e[48;5;197;38;5;232;1m"
    $PSStyle.FileInfo.Extension[".bmp"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".dicom"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".tiff"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".tif"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".TIFF"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".cdr"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".flif"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".gif"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".icns"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".ico"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".jpeg"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".JPG"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".jpg"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".jxl"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".nth"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".png"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".psd"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".pxd"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".pxm"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".xpm"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".webp"] = "`e[38;5;97m"
    $PSStyle.FileInfo.Extension[".ai"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".eps"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".epsf"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".drw"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".ps"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".svg"] = "`e[38;5;99m"
    $PSStyle.FileInfo.Extension[".avi"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".divx"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".IFO"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".m2v"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".m4v"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".mkv"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".MOV"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".mov"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".mp4"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".mpeg"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".mpg"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".ogm"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".rmvb"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".sample"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".wmv"] = "`e[38;5;114m"
    $PSStyle.FileInfo.Extension[".3g2"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".3gp"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".gp3"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".webm"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".gp4"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".asf"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".flv"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".ts"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".ogv"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".f4v"] = "`e[38;5;115m"
    $PSStyle.FileInfo.Extension[".VOB"] = "`e[38;5;115;1m"
    $PSStyle.FileInfo.Extension[".vob"] = "`e[38;5;115;1m"
    $PSStyle.FileInfo.Extension[".ass"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".srt"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".ssa"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".sub"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".sup"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".vtt"] = "`e[38;5;117m"
    $PSStyle.FileInfo.Extension[".3ga"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".S3M"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".aac"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".amr"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".au"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".caf"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".dat"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".dts"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".fcm"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".m4a"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".mod"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".mp3"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".mp4a"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".oga"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".ogg"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".opus"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".s3m"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".sid"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".wma"] = "`e[38;5;137;1m"
    $PSStyle.FileInfo.Extension[".ape"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".aiff"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".cda"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".flac"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".alac"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".mid"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".midi"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".pcm"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".wav"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".wv"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".wvc"] = "`e[38;5;136;1m"
    $PSStyle.FileInfo.Extension[".afm"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".fon"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".fnt"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".pfb"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".pfm"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".ttf"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".otf"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".woff"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".woff2"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".PFA"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".pfa"] = "`e[38;5;66m"
    $PSStyle.FileInfo.Extension[".7z"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".a"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".arj"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".bz2"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".cpio"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".gz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".lrz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".lz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".lzma"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".lzo"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".rar"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".s7z"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".sz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".tar"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".tbz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".tgz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".warc"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".WARC"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".xz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".z"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zip"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zipx"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zoo"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zpaq"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zst"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zstd"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".zz"] = "`e[38;5;40m"
    $PSStyle.FileInfo.Extension[".apk"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".ipa"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".deb"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".rpm"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".jad"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".jar"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".ear"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".war"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".cab"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".pak"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".pk3"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".vdf"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".vpk"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".bsp"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".dmg"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".crx"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".xpi"] = "`e[38;5;215m"
    $PSStyle.FileInfo.Extension[".iso"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".img"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".bin"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".nrg"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".qcow"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".fvd"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".sparseimage"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".toast"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vcd"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vdi"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vhd"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vhdx"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vfd"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".vmdk"] = "`e[38;5;124m"
    $PSStyle.FileInfo.Extension[".swp"] = "`e[38;5;244m"
    $PSStyle.FileInfo.Extension[".swo"] = "`e[38;5;244m"
    $PSStyle.FileInfo.Extension[".tmp"] = "`e[38;5;244m"
    $PSStyle.FileInfo.Extension[".sassc"] = "`e[38;5;244m"
    $PSStyle.FileInfo.Extension[".pacnew"] = "`e[38;5;33m"
    $PSStyle.FileInfo.Extension[".un~"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".orig"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".BUP"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".bak"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".o"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".mdump"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".rlib"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".dll"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".aria2"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".dump"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".stackdump"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".zcompdump"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".zwc"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".part"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".r[0-9]{0,2}"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".zx[0-9]{0,2}"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".z[0-9]{0,2}"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".pid"] = "`e[38;5;248m"
    $PSStyle.FileInfo.Extension[".state"] = "`e[38;5;248m"
    $PSStyle.FileInfo.Extension[".err"] = "`e[38;5;160;1m"
    $PSStyle.FileInfo.Extension[".error"] = "`e[38;5;160;1m"
    $PSStyle.FileInfo.Extension[".stderr"] = "`e[38;5;160;1m"
    $PSStyle.FileInfo.Extension[".pcap"] = "`e[38;5;29m"
    $PSStyle.FileInfo.Extension[".cap"] = "`e[38;5;29m"
    $PSStyle.FileInfo.Extension[".dmp"] = "`e[38;5;29m"
    $PSStyle.FileInfo.Extension[".allow"] = "`e[38;5;112m"
    $PSStyle.FileInfo.Extension[".deny"] = "`e[38;5;196m"
    $PSStyle.FileInfo.Extension[".service"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".socket"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".swap"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".device"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".mount"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".automount"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".target"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".path"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".timer"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".snapshot"] = "`e[38;5;45m"
    $PSStyle.FileInfo.Extension[".lnk"] = "`e[38;5;39m"
    $PSStyle.FileInfo.Extension[".application"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".cue"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".description"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".directory"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".m3u"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".m3u8"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".md5"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".properties"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".sfv"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".theme"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".torrent"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".urlview"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".webloc"] = "`e[38;5;116m"
    $PSStyle.FileInfo.Extension[".asc"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".bfe"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".enc"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".gpg"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".signature"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".sig"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".p12"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".pem"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".pgp"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".p7s"] = "`e[38;5;192;3m"
    $PSStyle.FileInfo.Extension[".32x"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".cdi"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".fm2"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".rom"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".sav"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".st"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".a00"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".a52"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".A64"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".a64"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".a78"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".adf"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".atr"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".gb"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".gba"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".gbc"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".gel"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".gg"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".ggl"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".ipk"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".j64"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".nds"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".nes"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".sms"] = "`e[38;5;213m"
    $PSStyle.FileInfo.Extension[".8xp"] = "`e[38;5;121m"
    $PSStyle.FileInfo.Extension[".8eu"] = "`e[38;5;121m"
    $PSStyle.FileInfo.Extension[".82p"] = "`e[38;5;121m"
    $PSStyle.FileInfo.Extension[".83p"] = "`e[38;5;121m"
    $PSStyle.FileInfo.Extension[".8xe"] = "`e[38;5;121m"
    $PSStyle.FileInfo.Extension[".stl"] = "`e[38;5;216m"
    $PSStyle.FileInfo.Extension[".dwg"] = "`e[38;5;216m"
    $PSStyle.FileInfo.Extension[".ply"] = "`e[38;5;216m"
    $PSStyle.FileInfo.Extension[".wrl"] = "`e[38;5;216m"
    $PSStyle.FileInfo.Extension[".xib"] = "`e[38;5;208m"
    $PSStyle.FileInfo.Extension[".iml"] = "`e[38;5;166m"
    $PSStyle.FileInfo.Extension[".DS_Store"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".localized"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".CFUserTextEncoding"] = "`e[38;5;239m"
    $PSStyle.FileInfo.Extension[".nib"] = "`e[38;5;57m"
    $PSStyle.FileInfo.Extension[".car"] = "`e[38;5;57m"
    $PSStyle.FileInfo.Extension[".dylib"] = "`e[38;5;241m"
    $PSStyle.FileInfo.Extension[".entitlements"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".pbxproj"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".strings"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".storyboard"] = "`e[38;5;196m"
    $PSStyle.FileInfo.Extension[".xcconfig"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".xcsettings"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".xcuserstate"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".xcworkspacedata"] = "`e[1m"
    $PSStyle.FileInfo.Extension[".pot"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".pcb"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".mm"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".gbr"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".scm"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".xcf"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".spl"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".Rproj"] = "`e[38;5;11m"
    $PSStyle.FileInfo.Extension[".sis"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".1p"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".3p"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".cnc"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".def"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".ex"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".example"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".feature"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".ger"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".ics"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".map"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".mf"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".mfasl"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".mi"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".mtx"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".pc"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".pi"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".plt"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".rdf"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".ru"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".sch"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".sty"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".sug"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".tdy"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".tfm"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".tfnt"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".tg"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".vcard"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".vcf"] = "`e[38;5;7m"
    $PSStyle.FileInfo.Extension[".xln"] = "`e[38;5;7m"
}
