#!/bin/zsh

pip3 install pyserial --break-system-packages  # pyserialのインストール

brew install grep trash micro git  # 色々インストール
brew install --cask core-tunnel

# zshの設定ファイルとかのダウンロード
# ホームディレクトリの .remodeling_zsh.sh として保存
TARGET="${HOME}/.remodeling_zsh.sh"
URL="https://raw.githubusercontent.com/physics11688/miscellaneous/main/remodeling_zsh.sh"

if [ -f "$TARGET" ]; then
    echo -n "$TARGET はすでに存在します。上書きしますか？ (y or n): "
    read input
    case "$input" in
        [Yy]* )
            curl -o "$TARGET" "$URL"
            echo "ファイルを上書きしました。"
            ;;
        * )
            echo "既存のファイルを保持しました。"
            ;;
    esac
else
    curl -o "$TARGET" "$URL"
    echo "ファイルをダウンロードしました。"
fi

chmod +x "$HOME/.remodeling_zsh.sh"

touch "${HOME}/.zshrc"
# .zshrcに .remodeling_zsh.sh を読み込む設定を追記
if ! grep -q "source \$HOME/.remodeling_zsh.sh" ~/.zshrc; then
    echo 'source $HOME/.remodeling_zsh.sh' >> ~/.zshrc
fi



# zinitのインストール
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"



# 設定の反映 (ターミナル再起動してもいいけど)
source ~/.zshrc


if [ ! -d "${HOME}/macos-terminal-themes" ]; then
    git clone https://github.com/lysyi3m/macos-terminal-themes "${HOME}/macos-terminal-themes"
fi


open "$HOME/macos-terminal-themes/themes"

echo "開いたディレクトリから テーマ を選択してください"
