
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
let od_org = "OneDrive - 独立行政法人 国立高等専門学校機構"
let od_root = ([$home $od_org] | path join)

let shown = (
  if ($p | str starts-with $od_root) {
    # OneDrive配下を "OneDriveBusiness/..." に置換
    let rel = ($p | path relative-to $od_root)
    if ($rel == "" or $rel == null) {
      "OneDriveBusiness"
    } else {
      (["OneDriveBusiness" $rel] | path join)
    }
  } else if ($home != null and ($p | str starts-with $home)) {
    # 既存のホーム短縮（~）
    let rel = ($p | path relative-to $home)
    if ($rel == "" or $rel == null) {
      "~"
    } else {
      ([~ $rel] | path join)
    }
  } else {
    $p
  }
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
    else if $os_name == "windows" { "Win-7KUNDI5" }
    else if $os_name == "macos" { "LabMac" }
    else if $os_name != "unknown" { $"( $os_name )-7KUNDI5" }
    else { "Host-7KUNDI5" }
  )



  # 左にベースラインのみ表示

  # 左にベースラインのみ表示（最後に改行を付ける）
  let left = $"\n(ansi reset)[(ansi xterm_cyan1)( $user )(ansi reset)@(ansi xterm_palegreen1a)( $shown_host )(ansi reset):(ansi light_yellow_bold)( $shown )(ansi reset)]"
  $"( $left )\n"          # ← ここで改行を付加（(char nl) でもOK）

}


# ===== 右プロンプト（Git + 日付） =====
# シンプル版（例：2025-12-01 18:05）
$env.PROMPT_COMMAND_RIGHT = {||
  let g = (git_prompt)
  let t = (date now | format date "%Y-%m-%d %H:%M")
  [ "NuShell:" $g $t ] | where { |x| $x != "" } | str join "  "
}
