local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.audible_bell = "Disabled"

-- カラーテーマ
config.color_scheme = 'Dracula+'

-- フォント
config.font = wezterm.font('UDEV Gothic 35NF')
-- OSごとにフォントサイズを分岐
if wezterm.target_triple:find('darwin') then
  config.font_size = 18
else
  config.font_size = 14
end

-- デフォルトウィンドウサイズ
config.initial_cols = 80
config.initial_rows = 24

-- 余白
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- カーソル
config.default_cursor_style = 'SteadyBlock'

-- 物理キーコードで判定（Ctrl+Shift+2 を C-@ として正しく扱うため）
config.key_map_preference = 'Physical'

-- IME 有効化（Mac/Linux 共通。Mac は macOS IME、Linux は XIM/fcitx5）
config.use_ime = true

-- Linux(X11 + fcitx5) 専用設定
if wezterm.target_triple:find('linux') then
  -- 接続先IMをXMODIFIERS非依存で明示（env事故があっても fcitx に繋ぐ）
  config.xim_im_name = 'fcitx'
  -- 未確定文字列をwezterm自身が端末フォントでインライン描画（デフォルト）。
  -- これが効くには fcitx5側で On-The-Spot を有効にする必要がある:
  --   ~/.config/fcitx5/conf/xim.conf に（セクション見出し無しで） UseOnTheSpot=True
  config.ime_preedit_rendering = 'Builtin'
end

if wezterm.target_triple:find('darwin') then
   config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
end

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

-- タブ数で等分割するフラットタブバー
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 9999  -- WezTerm側の打ち切りを無効化し、コールバックに委ねる

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title
             or tab.active_pane.title
  local label = string.format(' %d: %s ', tab.tab_index + 1, title)

  if wezterm.column_width(label) > max_width then
    label = wezterm.truncate_right(label, max_width - 1) .. '…'
  end

  -- max_width まで空白で埋めて等幅にする
  local pad = max_width - wezterm.column_width(label)
  if pad > 0 then
    label = label .. string.rep(' ', pad)
  end

  -- Dracula+ パレット
  local bg = tab.is_active and '#6272a4' or (hover and '#44475a' or '#282a36')
  local fg = tab.is_active and '#f8f8f2' or '#6272a4'

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = label },
  }
end)

return config
