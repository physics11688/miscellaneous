
# Nushell setup script (robust, no "Extra positional argument"):
# - Overwrite $nu.config-path with ./config.nu
# - Copy each item under ./autoload/ into user autoload dirs (overwrite)
# - Create autoload dirs if missing or $nu.user-autoload-dirs is undefined
# - Backups before overwrite
# - Avoid long flags, glob pitfalls, and ensure parentheses, version compatibility

# ---- helpers ----
let ts = (date now | format date "%Y%m%d-%H%M%S")

# safe_get_names: handle ls column name differences across nushell versions
def safe_get_names [items: list<any>] {
  # Prefer 'name' column; fallback to first column if needed
  if (do { $items | is-empty } | default false) {
    []
  } else {
    let cols = ($items | columns)
    if ($cols | any {|c| $c == "name"}) {
      $items | get name
    } else {
      # fallback: pick the first column
      let first_col = ($cols | get 0)
      $items | get $first_col
    }
  }
}

# ---- validate sources ----
if !(path exists ./config.nu) {
  print "[ERROR] ./config.nu が見つかりません。カレントディレクトリに配置してください。"
  error make { msg: "config.nu missing" }
}

let has_autoload = (path exists ./autoload)
if !( $has_autoload ) {
  print "[WARN] ./autoload ディレクトリが見つかりません。config.nu のみを適用します。"
}

# ---- destinations ----
let config_dest = $nu.config-path
let config_dir  = ($config_dest | path dirname)
mkdir $config_dir

# backup root under config dir
let backup_root = ($config_dir | path join $"backup_($ts)")
mkdir $backup_root

# ---- config.nu backup & overwrite ----
if (path exists $config_dest) {
  let config_backup = ($backup_root | path join "config.nu.bak")
  # short flags only
  cp -f $config_dest $config_backup
  print $"[INFO] 既存の config.nu をバックアップ: ($config_backup)"
}

cp -f ./config.nu $config_dest
print $"[OK] config.nu を上書き: ($config_dest)"

# ---- resolve user autoload dirs ----
# if $nu.user-autoload-dirs is undefined, fallback to ~/.config/nushell/autoload
let fallback_autoload = ($config_dir | path join "autoload")
let target_dirs = (try { $nu.user-autoload-dirs } catch { [$fallback_autoload] })

# ensure each target dir exists
for d in $target_dirs {
  mkdir $d
}

# ---- autoload backup & overwrite (item-by-item, no globs) ----
if $has_autoload {
  # list items; do not use './autoload/*'
  let src_listing = (ls ./autoload)
  let src_items = (safe_get_names $src_listing)

  if ($src_items | is-empty) {
    print "[WARN] ./autoload は空です。コピーは行いません。"
  } else {
    for d in $target_dirs {
      try {
        # per-target backup dir
        let d_backup = ($d | path join $"backup_($ts)")
        mkdir $d_backup

        # copy each item with -f -r, backing up the same-named existing entries
        for item in $src_items {
          let base = (path basename $item)
          let src_item = (path join "./autoload" $base)
          let dest_item = ($d | path join $base)

          if (path exists $dest_item) {
            cp -f -r $dest_item $d_backup
          }

          cp -f -r $src_item $dest_item
        }

        print $"[OK] autoload を反映: ($d)  バックアップ: ($d_backup)"
      } catch err {
        # err may have 'msg' or different fields depending on nushell version; print generically
        print $"[ERROR] autoload コピーに失敗: ($d)  詳細: ($err)"
        # continue other dirs; do not abort entire script
      }
    }
  }
}

print "[DONE] 反映が完了しました。必要なら Nushell を再起動してください。"
