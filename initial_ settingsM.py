
import PySimpleGUI as sg
import os
import subprocess
import platform

pf = platform.system()
if 'Darwin' != pf:
    print(f"あなたが使用しているOSは {pf} ですが,\nこれはMac専用のプログラムのため何もせず終了します.")
    input("\n続行するにはなにかキーを押してください.")
    exit(0)


# PySimpleGUIの確認
freeze_output = subprocess.run("pip3 freeze", capture_output=True, text=True, shell=True).stdout
if not ("PySimpleGUI" in freeze_output):
    subprocess.run("pip3 install PySimpleGUI", shell=True)  # 無ければインストール


# ホームディレクトリへのパス
path_to_HOME = os.environ['HOME']

# アーキテクチャの確認
arch = subprocess.run("arch", capture_output=True, text=True, shell=True).stdout.replace("\n", "")


def Homebrew():
    """Homebrewがインストールされてるかチェックする関数"""
    if arch == "arm64":
        path_to_brew = "/opt/homebrew/bin"  # ファイルチェック
    else:
        path_to_brew = "/usr/local/bin/brew"

    if os.path.exists(path_to_brew):
        comment = "Homebrewは(おそらく)インストール済みです."
    else:
        cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        subprocess.run(cmd, shell=True)
        comment = "Homebrewはインストールされていなかったので,インストールしておきました."

    return comment


def Homebrewecho():
    """Homebrewのzshrcの設定状況をチェックする関数"""
    if arch != "arm64":
        return "あなたの使っているMacは古いので, Homebrewの設定は必要ありません.\n(M1では設定が必要です.)"

    path_to_zshrc = path_to_HOME + "/.zshrc"   # ファイルチェック
    if not os.path.exists(path_to_zshrc):   # 無ければ作って
        with open(path_to_zshrc, mode='w+') as f:
            f.write('export PATH="/opt/homebrew/bin:$PATH"\n\n')
            return "そもそもなんも作業してないでしょう？こちらで設定しておきました."  # return

    # .zshrcが存在する状況で
    with open(path_to_zshrc, mode='r') as f:  # 既存ファイル読み取り
        path_check = False
        for line in f:
            if 'export PATH="/opt/homebrew/bin:$PATH"' in line:  # 設定チェック
                path_check = True
    if path_check:
        return 'Homebrewは(おそらく)ちゃんと設定されています.\n他の不具合がある場合は,ターミナルを開いて\n      $ open -t ~/.zshrc \nを実行して\n【export PATH="/opt/homebrew/bin:$PATH"】\nという行が書き込まれているか自分で確認してください'
    else:
        with open(path_to_zshrc, mode='a') as f:  # 設定がなければ書き込んでしまう
            f.write('\nexport PATH="/opt/homebrew/bin:$PATH"\n\n')
        return 'export PATH=????? が設定されていなかったので設定しておきました.\nもし他の不具合がある場合は,ターミナルを開いて\n      $ open -t ~/.zshrc \nを実行して\n【export PATH="/opt/homebrew/bin:$PATH"】\nという行が書き込まれているか自分で確認してください'


def Brave():
    """Braveがインストールされているかチェックする関数"""
    # ファイルチェック
    cmd = "ls /Applications"
    output = subprocess.run(cmd, capture_output=True, text=True, shell=True).stdout
    if "Brave" in output:
        return "Braveはインストール済みです."
    else:
        cmd = "brew install --cask brave-browser"
        subprocess.run(cmd, shell=True)
        return "Braveがインストールされていなかったので,こちらでやっておきました."


def Java():
    """JDKがインストールされてるかチェックする関数"""
    if arch == "arm64":
        path_to_jdk = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk"  # PATHチェック
    else:
        path_to_jdk = "/usr/local/opt/openjdk/libexec/openjdk.jdk"

    if not os.path.exists(path_to_jdk):
        cmd = "brew install openjdk"
        subprocess.run(cmd, shell=True)
        return "Javaがインストールされていなかったので,インストールしておきました."
    else:
        # javacで確認
        javac = f"{path_to_jdk}/Contents/Home/bin/javac --version"
        proc = subprocess.run(javac, shell=True)
        if proc.returncode != 0:
            cmd = "brew install openjdk"
            subprocess.run(cmd, shell=True)
            return "Javaがインストールされていなかったので,インストールしておきました."
        else:
            return "Javaはちゃんとインストールされています."


def JavaSetting():
    # Javaの設定確認1
    # リンクのチェック
    path_to_link = "/Library/Java/JavaVirtualMachines/openjdk.jdk"
    if arch == "arm64":
        path_to_jdk = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk"  # PATHチェック
    else:
        path_to_jdk = "/usr/local/opt/openjdk/libexec/openjdk.jdk"

    if not os.path.exists(path_to_link):
        print("Macにログインするときのパスワードを入力してください.")
        cmd = f"sudo ln -sfn {path_to_jdk} {path_to_link}"
        subprocess.run(cmd, shell=True)
        comment = "「Java を書きやすくする設定 1」は正しく実行できていませんでしたので,\nこちらでやっておきました.\n\n"
    else:
        comment = "「Java を書きやすくする設定 1」は正しく実行されています.\n\n"

    # Javaの設定確認2
    # .zshrcのチェック
    # JAVA_HOMEの設定
    path_to_zshrc = path_to_HOME + "/.zshrc"
    if not os.path.exists(path_to_zshrc):
        with open(path_to_zshrc, mode='w+') as f:
            f.write(
                '\nexport JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk"\nexport PATH="${JAVA_HOME}/Contents/Home/bin:${PATH}"\n\n')
            comment = comment + \
                'そもそもなんもzshrcの設定がなされていないです.\n【export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk"】\n【export PATH="${JAVA_HOME}/Contents/Home/bin:${PATH}"】の2行 はこちらで書き込みました.\n\n'
    else:  # JAVA_HOMEの設定 (.zshrc自体はある)
        with open(path_to_zshrc, mode='r') as f:  # 読み込み
            javahome_check = False  # 内容のチェック
            for line in f:
                if 'export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk"' in line:
                    javahome_check = True
        if javahome_check:
            comment = comment + \
                '「Java を書きやすくする設定 2」は(おそらく)正しく行われています.\n\nもし他の不具合がある場合は,ターミナルを開いて\n      open -t ~/.zshrc \nを実行して中身をチェックしてみてください.\n\n'
        else:
            with open(path_to_zshrc, mode='a') as f:   # 追記
                f.write('\nexport JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk"\n')
                comment = comment + '「Java を書きやすくする設定 2」は正しく実行されていませんでした.\n【export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk"】 という行をこちらで書き込みました.\nもし他の不具合がある場合は,ターミナルを開いて\n      open -t ~/.zshrc \nを実行して中身をチェックしてみてください.\n\n'

    # Javaの設定確認3
    # PATHを通す export PATH="${{JAVA_HOME}}/Contents/Home/bin:$PATH"
    with open(path_to_zshrc, mode='r') as f:  # .zshrcのチェック
        path_check = False
        for line in f:
            if 'export PATH="${JAVA_HOME}/Contents/Home/bin:${PATH}"' in line:
                path_check = True
    if not path_check:
        with open(path_to_zshrc, mode='a') as f:  # 追記
            f.write('\nexport PATH="${JAVA_HOME}/Contents/Home/bin:${PATH}"\n')
            comment = comment + \
                'Java を書きやすくする設定 3. は実行されていませんでした.\n【export PATH="${JAVA_HOME}/Contents/Home/bin:${PATH}"】 という行をこちらで書き込みました.\nもし他の不具合がある場合は,ターミナルを開いて\n      open -t ~/.zshrc \nを実行して中身をチェックしてみてください.'
    else:
        comment = comment + \
            '「Java を書きやすくする設定 3」は(おそらく)正しく行われています.\nもし他の不具合がある場合は,ターミナルを開いて\n      open -t ~/.zshrc \nを実行して中身をチェックしてみてください.'

    return comment


questions = {
    'Homebrew': 'Homebrewはちゃんとインストールされてる？',
    'Homebrewecho': 'Homebrewインストール後の\n【 echo \'export PATH="/opt/homebrew/bin:$PATH"\' >> ${HOME}/.zshrc 】\nはちゃんと入力できてる？',
    'Brave': 'Brave(Webブラウザ)はインストールされてる？',
    'Java': 'Javaはインストールされてる？',
    'JavaSetting': 'Javaを書きやすくする設定はちゃんと出来てる？'}

msg = """
これは「低学年が高専沼にどっぷりハマるための Mac OS 初期設定 」の答え合わせプログラムです.

特に初心者が「うまく行っているか自分でわかりにくい」ターミナルでの設定の答え合わせを行います.

↓ から答え合わせをしたい項目を選んでください
"""
sg.theme('Dark Brown')

# 位置
left = 0
right = 0
top = 50

bottom = 50
layout = [
    [sg.Text(msg, size=(80, 10), font=('Arial', 15))],
    [sg.Checkbox('Homebrewはちゃんとインストールされてる？', default=True, font=('Arial', 15), key='Homebrew')],
    [sg.Checkbox('Homebrewインストール後の【 echo \'export PATH???】はちゃんと入力できてる？', font=('Arial', 15), key='Homebrewecho')],
    [sg.Checkbox('Brave(Webブラウザ)はインストールされてる？', font=('Arial', 15), key='Brave')],
    [sg.Checkbox('Javaはインストールされてる？', font=('Arial', 15), key='Java')],
    [sg.Checkbox('Javaを書きやすくする設定はちゃんと出来てる？', font=('Arial', 15), key='JavaSetting')],
    [sg.Push(), sg.Button('答え合わせする', font=('Arial', 15), size=(30, 2), pad=((left, right), (top, bottom)), key='-Btn-'), sg.Push()]
]

window = sg.Window('Mac初期設定答え合わせプログラム', layout)

while True:

    event, value = window.read()  # イベントの入力を待つ

    if event == '-Btn-':
        for q in value:
            if value[q]:
                func = eval(q)
                comment = func()
                sg.popup(comment, font=('Noto Serif CJK JP', 18))
        break

    elif event is None:
        break

window.close()
