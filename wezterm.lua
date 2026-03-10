local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ─── Smart navigation (Neovim ↔ WezTerm panes) ─────────────────────────────
-- Uses IS_NVIM user var set by smart-splits.nvim (do NOT use get_foreground_process_name, it causes lag)
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

-- ─── Leader key (tmux-style Ctrl+b) ──────────────────────────────────────────
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

-- ─── Key bindings ─────────────────────────────────────────────────────────────
config.keys = {

  -- ── Panes ──────────────────────────────────────────────────────────────────
  -- Split vertically (like Ctrl+b %)
  { key = '%', mods = 'LEADER|SHIFT', action = wezterm.action.SplitPane { direction = 'Right' } },
  -- Split horizontally (like Ctrl+b ")
  { key = '"', mods = 'LEADER|SHIFT', action = wezterm.action.SplitPane { direction = 'Down' } },
  -- Move between panes (Ctrl+b + arrow)
  { key = 'LeftArrow',  mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  -- Smart pane navigation (Ctrl+hjkl, seamless with Neovim via smart-splits.nvim)
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  -- Smart pane resizing (Alt+hjkl, seamless with Neovim)
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),
  -- Zoom pane toggle (Ctrl+b z)
  { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },
  -- Close pane (Ctrl+b x)
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- ── Tabs (windows in tmux) ─────────────────────────────────────────────────
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '0', mods = 'LEADER', action = wezterm.action.ActivateTab(0) },
  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(1) },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(2) },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(3) },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(4) },
  { key = '5', mods = 'LEADER', action = wezterm.action.ActivateTab(5) },
  { key = '6', mods = 'LEADER', action = wezterm.action.ActivateTab(6) },
  { key = '7', mods = 'LEADER', action = wezterm.action.ActivateTab(7) },
  { key = '8', mods = 'LEADER', action = wezterm.action.ActivateTab(8) },
  { key = '9', mods = 'LEADER', action = wezterm.action.ActivateTab(9) },
  { key = '&', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = ',', mods = 'LEADER', action = wezterm.action.PromptInputLine {
    description = 'Rename tab:',
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }},

  -- ── Copy mode ──────────────────────────────────────────────────────────────
  { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },

  -- ── Session / misc ─────────────────────────────────────────────────────────
  { key = ':', mods = 'LEADER', action = wezterm.action.ActivateCommandPalette },
  { key = '?', mods = 'LEADER', action = wezterm.action.ShowDebugOverlay },
  { key = 'r', mods = 'LEADER', action = wezterm.action.ReloadConfiguration },
}

-- ─── Copy mode vim keys ───────────────────────────────────────────────────────
config.key_tables = {
  copy_mode = {
    { key = 'h', action = wezterm.action.CopyMode 'MoveLeft' },
    { key = 'j', action = wezterm.action.CopyMode 'MoveDown' },
    { key = 'k', action = wezterm.action.CopyMode 'MoveUp' },
    { key = 'l', action = wezterm.action.CopyMode 'MoveRight' },
    { key = 'w', action = wezterm.action.CopyMode 'MoveForwardWord' },
    { key = 'b', action = wezterm.action.CopyMode 'MoveBackwardWord' },
    { key = '0', action = wezterm.action.CopyMode 'MoveToStartOfLine' },
    { key = '$', action = wezterm.action.CopyMode 'MoveToEndOfLineContent' },
    { key = 'g', action = wezterm.action.CopyMode 'MoveToScrollbackTop' },
    { key = 'G', action = wezterm.action.CopyMode 'MoveToScrollbackBottom' },
    { key = 'u', mods = 'CTRL', action = wezterm.action.CopyMode 'PageUp' },
    { key = 'd', mods = 'CTRL', action = wezterm.action.CopyMode 'PageDown' },
    { key = 'v', action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' } },
    { key = 'V', action = wezterm.action.CopyMode { SetSelectionMode = 'Line' } },
    { key = 'v', mods = 'CTRL', action = wezterm.action.CopyMode { SetSelectionMode = 'Block' } },
    { key = 'y', action = wezterm.action.Multiple {
      wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
      wezterm.action.CopyMode 'Close',
    }},
    { key = 'q',      action = wezterm.action.CopyMode 'Close' },
    { key = 'Escape', action = wezterm.action.CopyMode 'Close' },
  },
}

-- ─── Shell & appearance ──────────────────────────────────────────────────────
config.default_prog = { 'C:/Program Files/PowerShell/7/pwsh.exe', '-NoLogo' }
config.color_scheme = 'Solarized Dark (Gogh)'

return config
