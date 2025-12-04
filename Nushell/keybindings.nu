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
