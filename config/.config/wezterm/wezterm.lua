local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- カラーテーマ
config.color_scheme = 'Ubuntu'

-- フォント
config.font = wezterm.font('Ricty ShinDiminished')
config.font_size = 16

-- デフォルトウィンドウサイズ
config.initial_cols = 80
config.initial_rows = 24

-- 余白
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- カーソル
config.default_cursor_style = 'SteadyBlock'

-- 物理キーコードで判定（Ctrl+Shift+2 を C-@ として正しく扱うため）
config.key_map_preference = 'Physical'

-- XIM経由でFcitx5にキーイベントを渡す（日本語入力に必要）
config.use_ime = true

-- 選択時にクリップボードへコピー
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
  },
}

-- キーバインド (Terminator風)
config.keys = {
  -- 画面分割
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'o', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- 分割ペイン間の移動
  { key = 'UpArrow',    mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down'  },
  { key = 'LeftArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },

  -- ペインの最大化/元に戻す
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.TogglePaneZoomState },

  -- ペインを閉じる
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = false } },

  -- Ctrl+Shift+2 → Emacs C-@ (mark-set) に NUL を送る
  {
    key = '2',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      pane:send_text '\x00'
    end),
  },
}

return config
