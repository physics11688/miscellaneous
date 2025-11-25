#!/bin/bash



set -e  # エラーで停止

# OS基本情報
os_name=$(uname -s)
arch=$(uname -m)
os_release="/etc/os-release"

if [ "$os_name" = "Darwin" ]; then
    os_name="Mac"
elif [ "$os_name" = "Linux" ]; then
    if grep -qi microsoft /proc/version; then
        os_name="WSL"
    elif [ -n "$MULTIPASS_INSTANCE_NAME" ]; then
        os_name="Multipass"
    elif [ -f /run/cloud-init/cloud-id ] && grep -q "multipass" /run/cloud-init/cloud-id; then
        os_name="Multipass"
    elif [[ "$arch" == arm* ]] && grep -q "Raspberry Pi" /proc/cpuinfo; then
        os_name="RaspberryPi"
    else
        if [ -f "$os_release" ]; then
            os_name=$(grep '^ID=' "$os_release" | cut -d= -f2)
        else
            os_name="Linux"
        fi
    fi
fi

echo "OS: $os_name"

touch "${HOME}/.zshrc"


# For MacOS
if [ "$os_name" = "Mac" ]; then
    # pip3の設定
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.zshrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
    fi

    pip3 install pyserial --user  # pyserialのインストール
    # brewのチェック
    if ! command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
    echo "❌ Homebrew がインストールされていません。スクリプトを終了します。"
    exit 1
    fi

    if ! grep -q 'brew shellenv' "${HOME}/.zshrc"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zshrc"
        eval "$(/opt/homebrew/bin/brew shellenv)"  # 今のセッションにも反映
    fi
    brew update
    brew upgrade
    brew upgrade --cask
    brew cleanup
    brew install grep trash micro git coreutils  # 色々インストール
else
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt install -y \
        zsh git curl build-essential \
        python3 python3-pip \
        clang clang-format \
        ranger unattended-upgrades trash-cli \
        cmake gdb lldb llvm-dev liblldb-dev trash-cli micro
    if [ "$os_name" = "RaspberryPi" ]; then
    sudo apt install -y \
    language-pack-ja-base \
    language-pack-ja \
    manpages-ja \
    manpages-ja-dev \
    pulseaudio-module-bluetooth \
    fonts-ipafont \
    fonts-ipaexfont \

    sudo update-locale LANG=ja_JP.UTF8
    fi

    sudo sed -i 's/^# *ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
    sudo locale-gen || true
    sudo update-locale LANG=ja_JP.UTF-8 || true
    sudo timedatectl set-timezone Asia/Tokyo || true
    # zsh使用
    sudo usermod -s "$(which zsh)" $(whoami)

fi



# zshの設定ファイルとかのダウンロード
# ホームディレクトリの .remodeling_zsh.sh として保存
TARGET="${HOME}/.remodeling_zsh.sh"
URL="https://raw.githubusercontent.com/physics11688/miscellaneous/main/remodeling_zsh.sh"
download_flag=false

if [ -f "$TARGET" ]; then
    echo -n "$TARGET はすでに存在します。上書きしますか？ (y or n): "
    read input
    case "$input" in
        [Yy]* ) download_flag=true ;;
        * ) echo "既存のファイルを保持しました。" ;;
    esac
else
    download_flag=true
fi

if $download_flag; then
    curl -o "$TARGET" "$URL"
    if [[ "$os_name" == "Mac" ]]; then
        sed -i '' "s/b@Mac/b@${os_name}/g" "$TARGET"
    else
        sed -i "s/b@Mac/b@${os_name}/g" "$TARGET"
    fi
    echo "設定ファイルを新規にダウンロードしました。"
fi

chmod +x "$HOME/.remodeling_zsh.sh"


# .zshrcに .remodeling_zsh.sh を読み込む設定を追記
if ! grep -q 'source $HOME/.remodeling_zsh.sh' ~/.zshrc; then
    echo "source \$HOME/.remodeling_zsh.sh" >> ~/.zshrc
fi



# zinitのインストール
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"





if [ "$os_name" = "Mac" ]; then
    if [ ! -d "${HOME}/macos-terminal-themes" ]; then
        git clone https://github.com/lysyi3m/macos-terminal-themes "${HOME}/macos-terminal-themes"
    fi


    open "$HOME/macos-terminal-themes/themes"
    osascript -e 'display dialog "開いたディレクトリから テーマ を選択してください" buttons {"OK"} default button "OK"'

    # echo "開いたディレクトリから テーマ を選択してください"
fi

# 設定の反映 (ターミナル再起動してもいいけど)
exec zsh
