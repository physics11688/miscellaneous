import os
import glob
import json


# 手動で LOCALAPPDATA を指定（必要に応じて変更）
local_appdata = os.path.expanduser("~\\AppData\\Local")

# 検索パターン
search_pattern = os.path.join(local_appdata, "Packages", "Microsoft.WindowsTerminal*")

# 一致するディレクトリを取得
matching_dirs = glob.glob(search_pattern)

# 結果表示
if not matching_dirs:
    print("Windows Terminal の設定ディレクトリが見つかりません.")
    exit(1)


# Windows Terminal の設定ファイルパス
settings_path = os.path.join(matching_dirs[0], "LocalState", "settings.json")


# ファイルが存在するか確認
if not os.path.exists(settings_path):
    print("Windows Terminal の設定ファイルが見つかりません.")
    exit(1)

# JSON 読み込み
with open(settings_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# PowerShell 7 のプロファイルを探す
pwsh_profile = None
for profile in data.get("profiles", {}).get("list", []):
    if "Windows.Terminal.PowershellCore" in profile.get("source", ""):
        pwsh_profile = profile
        break

if not pwsh_profile:
    print("PowerShell 7 のプロファイルが見つかりません.")
    exit(1)


# 既定プロファイルに設定
if data["defaultProfile"] != pwsh_profile["guid"]:
    print("Windows Terminalの既定プロファイルが PowerShell 7 ではありません.")

    while True:
        answer = (
            input("既定プロファイルを PowerShell 7 に変更しますか? (y/n): ")
            .strip()
            .lower()
        )

        if answer in ["y", "yes"]:
            print("続行します.")
            break
        elif answer in ["n", "no"]:
            print("中止します.")
            exit(0)
        else:
            print("無効な入力です.y または n を入力してください.")

data["defaultProfile"] = pwsh_profile["guid"]


# JSON を保存
with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)

print("Windows Terminal の設定を完了しました.")
