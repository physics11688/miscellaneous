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

# PATHに追加

$env.PATH = (
  $env.PATH
  | append ($nu.home-path | path join 'local' 'bin')
  | uniq
)




# プロンプト変更
$env.PROMPT_INDICATOR = {|| $"(ansi '#ff5f87')$ (ansi reset)" }

$env.PROMPT_COMMAND = {||
  # 外部コマンドは ^ を付ける
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

  $"
(ansi reset)[(ansi cyan)($env.USERNAME)(ansi reset)@($host):(ansi yellow)($shown)(ansi reset)]
"
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


# keybind


# --- 既存 $env.config の安全初期化 ---
$env.config = ($env.config? | default {})

# --- Emacsモード（bash風） ---
$env.config.edit_mode = 'emacs'

# --- InlinePrediction 相当の色（ヒントの色） ---
# PSReadLine: InlinePrediction = '#9CA3AF'
# Nushellでは color_config.hints に相当
$env.config.color_config = ($env.config.color_config? | default {})
$env.config.color_config.hints = '#9CA3AF'

# --- 追加したいキーバインド群（PSReadLine設定を全て移植） ---


let _new_bindings = [
  # Tab：補完メニューを開く／開いていれば確定（enterにフォールバック）
  {
    name: "completion_menu_tab"
    modifier: none
    keycode: tab
    mode: [emacs, vi_insert, vi_normal]
    event: {
      until: [
        { send: menu, name: "completion_menu" }
        { send: enter }
      ]
    }
  }

  # Ctrl + D：終了（EOF）
  {
    name: "ctrl_d_exit_or_delete"
    modifier: control
    keycode: char_d
    mode: [emacs, vi_insert, vi_normal]
    event: { send: ctrld }
  }

  # Ctrl + L：画面クリア
  {
    name: "ctrl_l_clear_screen"
    modifier: control
    keycode: char_l
    mode: [emacs, vi_insert, vi_normal]
    event: { send: clearscreen }
  }

  # Ctrl + R：履歴検索（インクリメンタルサーチ）
  {
    name: "ctrl_r_search_history"
    modifier: control
    keycode: char_r
    mode: [emacs, vi_insert, vi_normal]
    event: { send: searchhistory }
  }

  # Alt + . ：直前コマンドの最後の引数を挿入（bash互換）— 実在イベントが無いので自作
  {
    name: "alt_period_yank_last_arg"
    modifier: alt
    keycode: char_.     # ← char_<文字> 形式。ドットは 'char_.'
    mode: [emacs, vi_insert, vi_normal]
    event: {
      send: executehostcommand
      cmd: (
        let cmds = (history | last 1 | get command);
        if ($cmds | is-empty) { null } else {
          let line = ($cmds | first | str trim);
          let parsed = ($line | parse --regex '.*?([^\\s]+)$' | get capture0);
          if ($parsed | is-empty) { null } else {
            let last = ($parsed | first);
            commandline edit --insert $last    # バッファ編集の公式コマンド
          }
        }
      )
    }
  }

  # Ctrl + ← / → ：単語単位で移動（EditCommand：**CamelCase**）
  {
    name: "ctrl_left_word"
    modifier: control
    keycode: left
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: MoveWordLeft }
  }
  {
    name: "ctrl_right_word"
    modifier: control
    keycode: right
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: MoveWordRight }
  }

  # Ctrl + ↑ ：前の単語を削除（PSReadLine: BackwardKillWord）
  {
    name: "ctrl_up_cut_prev_word"
    modifier: control
    keycode: up
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: BackspaceWord }
  }

  # Ctrl + ↓ ：貼り付け（キルリング→失敗なら通常ペースト）
  {
    name: "ctrl_down_paste_fallback"
    modifier: control
    keycode: down
    mode: [emacs, vi_insert, vi_normal]
    event: {
      until: [
        { edit: PasteCutBufferAfter }  # 直前の Cut があれば貼れる
        { edit: Paste }                # ダメなら通常ペーストにフォールバック
      ]
    }
  }

  # Ctrl + Backspace ：前の単語を削除
  {
    name: "ctrl_backspace_cut_prev_word"
    modifier: control
    keycode: backspace
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: BackspaceWord }
  }

  # Ctrl + Delete ：次の単語を削除
  {
    name: "ctrl_delete_cut_next_word"
    modifier: control
    keycode: delete
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: CutWordRight }
  }

  # Ctrl + U ：行頭まで削除（PSReadLine: BackwardKillLine）
  {
    name: "ctrl_u_cut_from_line_start"
    modifier: control
    keycode: char_u
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: CutFromLineStart }
  }

  # Ctrl + K ：行末まで削除（PSReadLine: KillLine）
  {
    name: "ctrl_k_cut_to_line_end"
    modifier: control
    keycode: char_k
    mode: [emacs, vi_insert, vi_normal]
    event: { edit: CutToLineEnd }
  }

  # Ctrl + Y ：貼り付け（PSReadLineの “Yank” 寄りにしたい時はこちら）
  # { name: "ctrl_y_paste"
  #   modifier: control
  #   keycode: char_y
  #   mode: [emacs, vi_insert, vi_normal]
  #   event: { until: [ { edit: PasteCutBufferAfter } { edit: Paste } ] }
  # }
]



# --- 既存 keybindings とマージ ---
if ($env.config.keybindings? == null) {
  $env.config.keybindings = $_new_bindings
} else {
  $env.config.keybindings = ($env.config.keybindings | append $_new_bindings)
}
