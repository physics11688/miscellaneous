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
alias showp = ^py -c 'import serial.tools.list_ports as s; [print(p) for p in reversed(list(s.comports()))]'
alias update = ^winget upgrade --all --silent --accept-source-agreements --accept-package-agreements


# PATHに追加
let p = ($nu.home-path | path join 'local' 'bin')
if (($p | path exists) and (($p | path type) == 'dir')) {
  $env.PATH = ($env.PATH | append $p | uniq)
}







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





def pipupdate [] {
  # このブロック内だけ pip のバージョンチェック通知を抑止
  with-env { PIP_DISABLE_PIP_VERSION_CHECK: '1' } {
    # 1) 取得（--quiet で冗長出力を抑制）
    let raw = (^py -m pip list --outdated --format=json --quiet)

    # 2) 空文字なら '[]' に置き換え（from json を必ず成功させる）
    let safe = (if ($raw | str trim | is-empty) { '[]' } else { $raw })

    # 3) JSON → テーブル化（不正JSONなら try で捕捉）
    let data = (try { $safe | from json } catch { [] })

    # 4) name 列だけ抽出（空配列ならそのまま空）
    let pkgs = (if ($data | is-empty) { [] } else { $data | get name })

    if ($pkgs | is-empty) {
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
    {
        name: "completion_menu_tab"
        modifier: none
        keycode: tab
        mode: [emacs, vi_insert, vi_normal]
        event: [
            { send: menu, name: "completion_menu" }
            { send: enter }
        ]
    }

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


# プロンプト変更
$env.PROMPT_INDICATOR = {|| $"(ansi '#ff5f87')$ (ansi reset)" }

$env.PROMPT_COMMAND = {||
  # 実ホスト名（必要なら別用途で使える）
  let host = (^hostname | str trim)

  # 現在のディレクトリ
  let p = (pwd)

  # HOME の決定（$nu.home-path があれば最優先、なければ $env.HOME）
  let home = (if ($nu.home-path? != null) { $nu.home-path } else { $env.HOME })

  # 表示用パス：
  # - ちょうど HOME のときは "~"
  # - HOME 配下なら "~\relative" にする
  # - それ以外はフルパス
  let shown = (
    if ($home != null and ($p | str starts-with $home)) {
      let rel = ($p | path relative-to $home)
      if ($rel == "" or $rel == null) { "~" } else { ([~ $rel] | path join) }
    } else {
      $p
    }
  )

  # ユーザー名の決定
  let user = (
    $env.USERNAME?                                           # Windows
    | default (
        $env.USER?                                           # Unix系
        | default (
            try { ^whoami | str trim | str replace -r '.*\\' '' }  # 最終フォールバック
            catch { "unknown" }
          )
      )
  )

  # OS 名（Nushell が提供）
  let os_name = ($nu.os-info.name? | default "unknown")

  # WSL 判定: 環境変数 or /proc/version の Microsoft 文字列
  let is_wsl = (
    ($env.WSL_DISTRO_NAME? != null)
    or (
      try { (open /proc/version | into string | str contains 'Microsoft') }
      catch { false }
    )
  )

  # if ブロック全体を () で包み 1式にする
  let shown_host = (
    if $is_wsl {
      "WSL-7KUNDI5"
    } else if $os_name == "windows" {
      "WIN-7KUNDI5"
    } else if $os_name == "macOS" {
      "LabMac"
    } else if $os_name != "unknown" {
      $"( $os_name )-7KUNDI5"  # ←補間は ($os_name) に修正
    } else {
      "Host-7KUNDI5"           # 最終フォールバック
    }
  )

  # ここも補間は ($var) 形式に統一
  $"
(ansi reset)[(ansi cyan)($user)(ansi reset)@($shown_host):(ansi yellow)($shown)(ansi reset)]
"
}
