# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# ウェルカムメッセージの非表示
$env.config = ($env.config | upsert show_banner false)

# エイリアス
alias ll = ls -l
alias showp = ^python3 -c 'import serial.tools.list_ports as s; [print(p) for p in reversed(list(s.comports()))]'



# 古い pip パッケージを安全に一括アップグレードする単一関数
# 使い方:
#   updatepip                     # 通常（pipも先に更新）
#   updatepip --user              # ユーザー領域にインストール
#   updatepip --dryrun            # 実行せず対象を表示
#   updatepip --pipfirst=false    # pip更新をスキップ
#   updatepip --ignore "pip,setuptools,wheel"  # 除外（カンマ区切り）
def updatepip [
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


if (($nu.os-info.name) != 'windows') {
  # モジュール（config.nu や別ファイル）から読み込んだ時にコマンドとして使えるように export def を推奨
  def updatezinit [] {
    ^zinit self-update --all
    ^zinit update
  }
}



if ($nu.os-info.name) == 'windows' {
  alias update = ^winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
} else if ($nu.os-info.name) == 'macos' {
    def update  [] {
         brew update
         brew upgrade
         brew upgrade --cask
         brew cleanup
    }
} else if ($nu.os-info.name) == 'linux' {

    def update [] {
         sudo apt update
         sudo apt -y upgrade
         sudo apt -y autoremove
    }
}







# PATHに追加



# 存在すれば PATH に追加（重複は追加しない）

def --env add-to-path-if-exists [
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



add-to-path-if-exists ($env.ProgramFiles | path join 'LLVM' | path join 'bin')
add-to-path-if-exists ($env.USERPROFILE | path join 'mingw64' | path join 'bin')
add-to-path-if-exists ($env.USERPROFILE | path join 'local' | path join 'bin')
# 先頭に入れたい場合
# add-to-path-if-exists ($env.USERPROFILE | path join 'mingw64' | path join 'bin') --prepend







# ユーザー（HKCU）の PATH だけを対象にする版
def path [Filter?: string] {
  # PowerShell経由で HKCU の Path を文字列として取得
  let user_path = (
    ^powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','User')"
    | str trim
  )

  let paths = (
    $user_path
    | split row ';'
    | where {|p| $p != '' }
  )

  if ($Filter != null and $Filter != '') {
    $paths | where {|p| $p | str contains $Filter }
  } else {
    $paths
  }
}


# シリアルポート一覧を逆順で表示
def showp [] {
  ^py -c 'import serial.tools.list_ports as s; [print(p) for p in reversed(list(s.comports()))]'
}



# 1つの位置引数 (string 型) を受け取る例
def gitpush [msg: string] {
    ^git add .
    ^git commit -m $msg
    ^git push
}




def pipupdate [] {
  # このブロック内だけ pip のバージョンチェック通知を抑止
  with-env { PIP_DISABLE_PIP_VERSION_CHECK: '1' } {
    # 1) 取得（--quiet で冗長出力を抑制）
    let raw = (^py -m pip list --outdated --format=json --quiet)

    # 2) 空文字なら '[]' に置き換え（from json を必ず成功させる）
    let r = ($raw | default "" | str trim)

let safe = (if (is-empty $r) { '[]' } else { $raw })


    # 3) JSON → テーブル化（不正JSONなら try で捕捉）
    let data = (try { $safe | from json } catch { [] })

    # 4) name 列だけ抽出（空配列ならそのまま空）
let d = ($data | default [])
let pkgs = (if (is-empty $d) { [] } else { $d | get name })

if (is-empty ($pkgs | default [])) {
  print "No outdated packages."
  return
}


    # 5) アップグレード実行（進捗表示）
    $pkgs | each { |pkg|
      print $"Updating: (ansi magenta)($pkg)(ansi reset)"
      ^py -m pip install --upgrade $pkg
    }
  }
}


# ========== 安全初期化 ==========
$env.config = ($env.config? | default {})
$env.config.color_config = ($env.config.color_config? | default {})
$env.config.keybindings = ($env.config.keybindings? | default [])

# ========== 基本設定 ==========
# Emacs モード
$env.config.edit_mode = "emacs"

# ヒント色（PSReadLine InlinePrediction 相当）
$env.config.color_config.hints = "#9CA3AF"



# ========== PSReadLine 相当キーバインド再現 ==========
let _new_bindings = [
    # TAB: 補完メニュー → 既に開いていれば確定
    # {
    #     name: "completion_menu_tab"
    #     modifier: none
    #     keycode: tab
    #     mode: [emacs, vi_insert, vi_normal]
    #     event: [
    #         { send: menu, name: "completion_menu" }
    #         { send: enter }
    #     ]
    # }

    # Ctrl + D: EOF
    {
        name: "ctrl_d_exit"
        modifier: control
        keycode: char_d
        mode: [emacs, vi_insert, vi_normal]
        event: { send: ctrld }
    }

    # Ctrl + L: clear
    {
        name: "ctrl_l_clear"
        modifier: control
        keycode: char_l
        mode: [emacs, vi_insert, vi_normal]
        event: { send: clearscreen }
    }

    # Ctrl + R: 履歴検索
    {
        name: "ctrl_r_search_history"
        modifier: control
        keycode: char_r
        mode: [emacs, vi_insert, vi_normal]
        event: { send: searchhistory }
    }

    # Ctrl + Backspace: 前の単語 Cut
    {
        name: "ctrl_backspace_cut_prev_word"
        modifier: control
        keycode: backspace
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: CutWordLeft }
    }

    # Ctrl + Delete: 次の単語 Cut
    {
        name: "ctrl_delete_cut_next_word"
        modifier: control
        keycode: delete
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: CutWordRight }
    }

    # Ctrl + U: 行頭まで Cut
    {
        name: "ctrl_u_cut_from_line_start"
        modifier: control
        keycode: char_u
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: CutFromLineStart }
    }

    # Ctrl + K: 行末まで Cut
    {
        name: "ctrl_k_cut_to_line_end"
        modifier: control
        keycode: char_k
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: CutToLineEnd }
    }

    # Ctrl + ←: 単語左
    {
        name: "ctrl_left_move_word"
        modifier: control
        keycode: left
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: MoveWordLeft }
    }

    # Ctrl + →: 単語右
    {
        name: "ctrl_right_move_word"
        modifier: control
        keycode: right
        mode: [emacs, vi_insert, vi_normal]
        event: { edit: MoveWordRight }
    }

# Ctrl + ↑: kill-ring の内容を前に貼り付け
{
    name: "ctrl_down_yank"
    modifier: control
    keycode: down
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: PasteCutBufferBefore }
}

# Ctrl + ↓: kill-ring の内容を後ろに貼り付け（必要なら）
{
    name: "ctrl_upda_yank"
    modifier: control
    keycode: up
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: CutWordLeft }
}

]




# ========== キーバインドを確実にマージ（エラーなし版） ==========
# append は値をそのまま *1要素として追加* するため、
# for loop で 1つずつ入れるのが最も安全でエラーが出ない方式。

for binding in $_new_bindings {
    $env.config.keybindings = $env.config.keybindings | append $binding
}



# # プロンプト変更
# $env.PROMPT_INDICATOR = {|| $"(ansi '#ff5f87')$ (ansi reset)" }

# $env.PROMPT_COMMAND = {||
#   # 外部コマンドは ^ を付ける
#   let host = (^hostname | str trim)

#   # 現在のディレクトリ
#   let p = (pwd)

#   # HOME の決定（$nu.home-path があれば最優先、なければ $env.HOME）
#   let home = (if ($nu.home-path? != null) { $nu.home-path } else { $env.HOME })

#   # 表示用パス：
#   # - ちょうど HOME のときは "~"
#   # - HOME 配下なら "~\relative" にする
#   # - それ以外はフルパス
#   let shown = (
#     if ($home != null and ($p | str starts-with $home)) {
#       let rel = ($p | path relative-to $home)
#       if ($rel == "" or $rel == null) { "~" } else { ([~ $rel] | path join) }
#     } else {
#       $p
#     }
#   )


# # 文字列の前でユーザー名を決定
# let user = (
#   $env.USERNAME?                                           # Windows
#   | default (
#       $env.USER?                                           # Unix系
#       | default (
#           try { ^whoami | str trim | str replace -r '.*\\' '' }  # 最終フォールバック
#           catch { "unknown" }
#         )
#     )
# )



# $"
# (ansi reset)[(ansi cyan)($user)(ansi reset)@($host):(ansi yellow)($shown)(ansi reset)]
# "

# }



# ===== 左プロンプト記号（$ のまま） =====
$env.PROMPT_INDICATOR = {|| $"(ansi '#ff5f87')$ (ansi reset)" }


# ===== Git ステータスを生成する関数（右プロンプト用） =====
def git_prompt [] {
  # 設定（好みで調整）
  let throttle_ms      = 300   # この時間以内はキャッシュを再利用
  let show_aheadbehind = false # ↑↓（リモート差分）は重いので既定OFF
  let show_untracked   = true  # 未管理ファイル（??）件数を出すか
  let show_stash       = false # stash 件数は重いので既定OFF

  # OSに応じたstderrの捨て先
  let devnull = (if ($nu.os-info.name? | default "unknown") == "windows" { "nul" } else { "/dev/null" })

  # 現在時刻（datetime）
  let now_dt = (date now)

  # リポジトリ判定（軽量）
  let in_repo = (
    try { ^git rev-parse --is-inside-work-tree err> $devnull | str trim }
    catch { "" }
  ) == "true"
  if not $in_repo { "" } else {
    # HEAD 表示（ブランチ or detached 短縮SHA）
    let branch    = (try { ^git symbolic-ref --short -q HEAD err> $devnull | str trim } catch { "" })
    let short_sha = (try { ^git rev-parse --short HEAD err> $devnull | str trim } catch { "" })
    let head_disp = (if ($branch | is-empty) { $"detached @ ( $short_sha )" } else { $branch })

    # 直近キャッシュ（無ければ null）
    let cache = ($env.__git_prompt_cache? | default null)
    let flags = { ab: $show_aheadbehind, ut: $show_untracked, st: $show_stash }

    # キャッシュ有効判定：cache が存在 & path/head/flags 一致 & 経過 < throttle
    let cache_valid = (
      $cache != null
      and ($cache.path == (pwd))
      and ($cache.head == $head_disp)
      and ($cache.flags == $flags)
      and (( $now_dt - $cache.ts ) < ($throttle_ms | into duration))
    )

    if $cache_valid {
      $cache.body
    } else {
      # 重い統計はトグルで制御
      let ahead_behind = (
        if $show_aheadbehind {
          (try {
            ^git rev-list --left-right --count @{upstream}...HEAD err> $devnull
            | str trim
            | split words
          } catch { [ "0", "0" ] })
        } else { [ "0", "0" ] }
      )
      let behind = ($ahead_behind | get 0 | into int)
      let ahead  = ($ahead_behind | get 1 | into int)

      # 変更件数（porcelain は比較的軽い）
      let porcelain = (
        try { ^git status --porcelain=v1 --ignore-submodules=dirty err> $devnull | lines }
        catch { [] }
      )
      let staged    = ($porcelain | where { |x| ($x | str substring 0..1) != " " } | length)
      let unstaged  = ($porcelain | where { |x| ($x | str substring 1..2) != " " } | length)
      let untracked = (if $show_untracked { ($porcelain | where { |x| ($x | str starts-with "??") } | length) } else { 0 })

      # stash 件数（トグル）
      let stash_count = (if $show_stash {
        (try { ^git stash list err> $devnull | lines | length } catch { 0 })
      } else { 0 })

      let is_dirty = ($staged + $unstaged + $untracked) > 0

      # 色
      let c_branch = (ansi green)
      let c_dim    = (ansi light_gray)
      let c_dirty  = (if $is_dirty { (ansi red) } else { (ansi light_gray) })
      let c_counts = (ansi yellow)
      let c_reset  = (ansi reset)

      # セグメント（1行で作る）
      let seg_branch = $"(ansi magenta)git:(ansi reset) ( $c_branch )( $head_disp )( $c_reset )"
      let seg_ahead  = (if ($show_aheadbehind and $ahead  > 0) { $" ↑( $ahead )" } else { "" })
      let seg_behind = (if ($show_aheadbehind and $behind > 0) { $" ↓( $behind )" } else { "" })
      let untracked_seg = (if ($show_untracked and $untracked > 0) { $" ??:( $untracked )" } else { "" })
      let seg_counts = (
        if $is_dirty {
          $"  ( $c_dirty )*( $c_reset ) ( $c_counts )stg:( $staged ) unstg:( $unstaged )( $untracked_seg )( $c_reset )"
        } else {
          $"  ( $c_dim )clean( $c_reset )"
        }
      )
      let seg_stash = (if ($show_stash and $stash_count > 0) { $"  stash:( $stash_count )" } else { "" })

      # パーツ結合（空文字除去）
      let parts = [ $seg_branch $seg_ahead $seg_behind $seg_counts $seg_stash ]
      let body  = ($parts | where { |x| $x != "" } | str join "")

      # キャッシュ更新（直近1件）
      $env.__git_prompt_cache = {
        ts: $now_dt,
        path: (pwd),
        head: $head_disp,
        flags: $flags,
        body: $body
      }

      # 右プロンプト用（角括弧でくくる）
      $"(ansi reset)(ansi '#5fd7ff')($body)"
    }
  }
}

# ===== 左プロンプト（ユーザ/ホスト/パス） =====
$env.PROMPT_COMMAND = {||
  # 現在ディレクトリ・HOME・表示パス
  let p = (pwd)
  let home = (if ($nu.home-path? != null) { $nu.home-path } else { $env.HOME })
  let shown = (
    if ($home != null and ($p | str starts-with $home)) {
      let rel = ($p | path relative-to $home)
      if ($rel == "" or $rel == null) { "~" } else { ([~ $rel] | path join) }
    } else { $p }
  )



  # ユーザー名
  let user = (
    $env.USERNAME?
    | default (
        $env.USER?
        | default (
            try { ^whoami | str trim | str replace -r '.*\\' '' }
            catch { "unknown" }
          )
      )
  )



  # OS/WSL → ホスト表示
  let os_name = ($nu.os-info.name? | default "unknown")
  let is_wsl = (
    ($env.WSL_DISTRO_NAME? != null)
    or (
      try { (open /proc/version | into string | str contains 'Microsoft') }
      catch { false }
    )
  )
  let shown_host = (
    if $is_wsl { "WSL-7KUNDI5" }
    else if $os_name == "windows" { "WIN-7KUNDI5" }
    else if $os_name == "macOS" { "LabMac" }
    else if $os_name != "unknown" { $"( $os_name )-7KUNDI5" }
    else { "Host-7KUNDI5" }
  )



  # 左にベースラインのみ表示

  # 左にベースラインのみ表示（最後に改行を付ける）
  let left = $"\n(ansi reset)[(ansi cyan)( $user )(ansi reset)@( $shown_host ):(ansi yellow)( $shown )(ansi reset)]"
  $"( $left )\n"          # ← ここで改行を付加（(char nl) でもOK）

}

# ===== 右プロンプト（Git ステータス） =====

# ===== 右プロンプト（Git + 日付） =====
# シンプル版（例：2025-12-01 18:05）
$env.PROMPT_COMMAND_RIGHT = {||
  let g = (git_prompt)
  let t = (date now | format date "%Y-%m-%d %H:%M")
  [ "NuShell:" $g $t ] | where { |x| $x != "" } | str join "  "
}
