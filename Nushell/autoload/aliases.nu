# エイリアス
alias ll = ls -l
alias showp = ^python3 -c 'import serial.tools.list_ports as s; [print(p) for p in reversed(list(s.comports()))]'

# 存在すれば PATH に追加（重複は追加しない）
# 先頭に入れたい場合
# add-to-path-if-exists ($env.USERPROFILE | path join 'mingw64' | path join 'bin') --prepend
export def --env add-to-path-if-exists [
  dir: string,
  --prepend
] {
  # 1) 存在確認（path exists は“パイプ入力”を受けます）
  if ($dir | path exists) {

    # 2) 既に PATH に入っているかを変数に
    let already = ($env.PATH | any {|p| $p == $dir })

    # 3) まだ入っていないなら追加
    if (not $already) {
      $env.PATH = if $prepend {
        [$dir] | append $env.PATH
      } else {
        $env.PATH | append $dir
      }
    }

  }
}


  export def updatezinit [] {
    if (($nu.os-info.name) != 'windows') {
  # モジュール（config.nu や別ファイル）から読み込んだ時にコマンドとして使えるように export def を推奨
    ^zinit self-update --all
    ^zinit update
  } else {
    print ''
  }
}

export def update-lib [] {
    if ($nu.os-info.name == 'windows') {
        ^winget source update
        ^winget upgrade --all --silent --accept-source-agreements --accept-package-agreements

    } else if ($nu.os-info.name == 'macos') {
        ^brew update
        ^brew upgrade
        ^brew upgrade --cask
        ^brew cleanup

    } else if ($nu.os-info.name == 'linux') {
        sudo apt update
        sudo apt -y upgrade
        sudo apt -y autoremove

    } else {
        print "Unsupported OS"
    }
}


if ($nu.os-info.name == 'windows') {
  add-to-path-if-exists ($env.ProgramFiles | path join 'LLVM' | path join 'bin')
  add-to-path-if-exists ($env.USERPROFILE | path join 'mingw64' | path join 'bin')
  add-to-path-if-exists ($env.USERPROFILE | path join 'local' | path join 'bin')
} else if ($nu.os-info.name == 'macos') {
  let brew_path = "/opt/homebrew/bin/brew"
    if ($brew_path | path exists) {
      let out = ^$brew_path shellenv
      $out
        | lines
        | where {|l| $l | str starts-with "export "}
        | each {|l|
            let line = ($l | str replace "export " "")
            let key = ($line | split row "=" | get 0)
            let val = ($line | split row "=" | get 1 | str trim -c '"')

            # ★ 動的な環境変数設定は load-env を使う
            load-env { $key: $val }
        }
}
  add-to-path-if-exists ($env.HOME | path join '.local' | path join 'bin')

} else if ($nu.os-info.name == 'linux') {
  add-to-path-if-exists ('/snap' | path join 'bin' )
}


# シリアルポート一覧を逆順で表示
export def showp [] {
  ^py -c 'import serial.tools.list_ports as s; [print(p) for p in reversed(list(s.comports()))]'
}



# 1つの位置引数 (string 型) を受け取る例
export def gitpush [msg: string] {
    ^git add .
    ^git commit -m $msg
    ^git push
}



# ユーザーの PATH だけを対象にする版
export def path [Filter?: string] {
    # ----------------------------
    # OS 判別
    # ----------------------------
    let os = $nu.os-info.name

    # ----------------------------
    # Windows: HKCU の User PATH を PowerShell 経由で取得
    # ----------------------------
    let paths = if $os == "windows" {
        let user_path = (
            ^powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','User')"
            | str trim
        )

        $user_path
        | split row ';'
        | where {|p| $p != '' }
    } else {
        # ----------------------------
        # macOS / Linux: 普通に $env.PATH を使う
        # ----------------------------
        $env.PATH
        | split row ':'
        | where {|p| $p != '' }
    }

    # ----------------------------
    # Filter の有無
    # ----------------------------
    if ($Filter != null and $Filter != '') {
        $paths | where {|p| $p | str contains $Filter }
    } else {
        $paths
    }
}



# 古い pip パッケージを安全に一括アップグレードする単一関数
# 使い方:
#   updatepip                     # 通常（pipも先に更新）
#   updatepip --user              # ユーザー領域にインストール
#   updatepip --dryrun            # 実行せず対象を表示
#   updatepip --pipfirst=false    # pip更新をスキップ
#   updatepip --ignore "pip,setuptools,wheel"  # 除外（カンマ区切り）
export def updatepip [
  --user,                         # boolean switch（型注釈なし）
  --dryrun,                       # boolean switch
  --pipfirst,                     # boolean switch（デフォは true にしたいので後段で補正）
  --ignore: string = ""           # 値付きオプションは型注釈OK
] {
  # --- Pythonランチャー自動選択（py > python3 > python） ---
  let py = (
    if (which py | length) > 0 { 'py' }
    else if (which python3 | length) > 0 { 'python3' }
    else { 'python' }
  )

  # --- pip を先に更新するかの補正（switchは存在= true / 不在= false）
  # 既定で更新したいので、スイッチが指定されなかった場合は true 扱いにする
let do_pip_first = (if (is-empty $pipfirst) { true } else { $pipfirst })


  if $do_pip_first {
    ^($py) -m pip install --upgrade pip
  }

  # --- 古いパッケージ一覧を JSON で取得 ---
  let pkgs = (^($py) -m pip list --outdated --format=json | from json)

  # --- 除外リスト（カンマ区切り→配列） ---
let i = ($ignore | default "" | str trim)

let ignore_list = (
  if (is-empty $i) {
    []
  } else {
    $i | split row ',' | each {|x| $x | str trim }
  }
)


  # --- 名前抽出＋除外適用 ---
  let names = (
    $pkgs
    | get name
    | where { |n| not ($n in $ignore_list) }
  )

  if (($names | length) == 0) {
    print "No outdated packages."
    return
  }

  if $dryrun {
    print "Outdated packages (dry-run):"
    $names | each { |n| print $" - ($n)" }
    return
  }

  # --- 実行：順にアップグレード ---
  for n in $names {
    if $user {
      ^($py) -m pip install -U --user $n
    } else {
      ^($py) -m pip install -U $n
    }
  }


let count = ($names | length)
# 補間ではなく連結にする
print ("✅ Completed: updated " + ($count | into string) + " package(s).")

}
