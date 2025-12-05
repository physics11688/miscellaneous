
# Nushell setup script (expression-safe):
# - Overwrite $nu.config-path with ./config.nu
# - Copy each item under ./autoload/ into user autoload dirs (overwrite)
# - Create autoload dirs if missing or $nu.user-autoload-dirs is undefined
# - Backups before overwrite
# - Avoid: glob, long flags, pipeline-in-if, wrong catch syntax

let ts = (date now | format date "%Y%m%d-%H%M%S")

# ----- validate sources -----
let has_config = (do { echo ./config.nu | path exists })
if (not $has_config) {
  print "[ERROR] ./config.nu が見つかりません。カレントディレクトリに配置してください。"
  error make { msg: "config.nu missing" }
}

let has_autoload = (do { echo ./autoload | path exists })
if (not $has_autoload) {
  print "[WARN] ./autoload ディレクトリが見つかりません。config.nu のみを適用します。"
}

# ----- destinations -----
let config_dest = $nu.config-path
let config_dir  = ($config_dest | path dirname)
mkdir $config_dir

# backup root under config dir
let backup_root = ($config_dir | path join $"backup_($ts)")
mkdir $backup_root

# ----- config.nu backup & overwrite -----
let dest_exists = (do { echo $config_dest | path exists })
if $dest_exists {
  let config_backup = ($backup_root | path join "config.nu.bak")
  cp -f $config_dest $config_backup
  print $"[INFO] 既存の config.nu をバックアップ: ($config_backup)"
}

cp -f ./config.nu $config_dest
print $"[OK] config.nu を上書き: ($config_dest)"

# ----- resolve user autoload dirs -----
let fallback_autoload = ($config_dir | path join "autoload")
let target_dirs = (try { $nu.user-autoload-dirs } catch { [$fallback_autoload] })

# ensure each target dir exists
for d in $target_dirs { mkdir $d }

# ----- autoload backup & overwrite (item-by-item, no globs) -----
if $has_autoload {
  let src_listing = (ls ./autoload)

  # 列名差に対応：name があるならそれ、無いなら先頭列から合成
  let has_name_col = ($src_listing | columns | any {|c| $c == "name"})
  let src_items = if $has_name_col {
    $src_listing | get name
  } else {
    let first_col = ($src_listing | columns | get 0)
    $src_listing | get $first_col | each {|n| path join "./autoload" $n }
  }

  let src_empty = ($src_items | is-empty)
  if $src_empty {
    print "[WARN] ./autoload は空です。コピーは行いません。"
  } else {
    for d in $target_dirs {
      try {
        let d_backup = ($d | path join $"backup_($ts)")
        mkdir $d_backup

        for src_item in $src_items {
          # basename はパイプで
          let base = (do { echo $src_item | path basename })
          let dest_item = ($d | path join $base)

          let dest_item_exists = (do { echo $dest_item | path exists })
          if $dest_item_exists {
            cp -f -r $dest_item $d_backup
          }

          cp -f -r $src_item $dest_item
        }

        print $"[OK] autoload を反映: ($d)  バックアップ: ($d_backup)"
      } catch { |err|
        print $"[ERROR] autoload コピーに失敗: ($d)  詳細: ($err)"
        # 続行
      }
    }
  }
}

print "[DONE] 反映が完了しました。必要なら Nushell を再起動してください。"
