local util = require("thaoe.util")

local M = {}

local default_theme = "dark"
local default_style = "normal"

local function read_palette_file()
  local paths = vim.api.nvim_get_runtime_file("colors.json", false)
  if #paths == 0 then
    vim.notify("thaoe: unable to locate colors.json on runtimepath", vim.log.levels.ERROR)
    return {}
  end

  local ok, lines = pcall(vim.fn.readfile, paths[1])
  if not ok then
    vim.notify("thaoe: failed to read colors.json - " .. tostring(lines), vim.log.levels.ERROR)
    return {}
  end

  local content = table.concat(lines, "\n")
  local decoded_ok, decoded = pcall(vim.json.decode, content)
  if not decoded_ok then
    vim.notify("thaoe: failed to parse colors.json - " .. tostring(decoded), vim.log.levels.ERROR)
    return {}
  end

  return decoded
end

local function copy_palette(colors)
  local result = {}
  for name, value in pairs(colors or {}) do
    if type(value) == "string" then
      result[name] = value
    end
  end
  return result
end

local function adjust_palette(colors, amount)
  local result = {}
  for name, value in pairs(colors or {}) do
    if type(value) == "string" then
      local ok, adjusted = pcall(util.lighten, value, amount)
      result[name] = ok and adjusted or value
    end
  end
  return result
end

local function select_style_branch(theme_branch, style_name)
  if type(theme_branch.styles) == "table" then
    return theme_branch.styles[style_name]
  end
  return theme_branch[style_name]
end

function M.load(theme_name, style_name)
  local palette = read_palette_file()
  if not palette or vim.tbl_isempty(palette) then
    return { theme = default_theme, style = default_style }
  end

  theme_name = theme_name or default_theme
  local branch = palette[theme_name]
  if not branch then
    vim.notify(
      string.format("thaoe: unknown theme '%s', falling back to '%s'", theme_name, default_theme),
      vim.log.levels.WARN
    )
    theme_name = default_theme
    branch = palette[theme_name]
  end

  style_name = style_name or default_style

  local style_branch = select_style_branch(branch, style_name)
  if not style_branch then
    if style_name ~= default_style then
      vim.notify(
        string.format("thaoe: unknown style '%s' for theme '%s', falling back to '%s'", style_name, theme_name, default_style),
        vim.log.levels.WARN
      )
      style_name = default_style
      style_branch = select_style_branch(branch, style_name)
    end
  end

  if not style_branch then
    vim.notify("thaoe: unable to locate palette style; aborting colorscheme", vim.log.levels.ERROR)
    return { theme = theme_name, style = style_name }
  end

  local result = vim.deepcopy(branch)
  result.theme = theme_name
  result.style = style_name

  if style_branch.normal and style_branch.bright then
    result.normal = vim.deepcopy(style_branch.normal)
    result.bright = vim.deepcopy(style_branch.bright)
    return result
  end

  local palette_normal = copy_palette(style_branch)
  local palette_bright

  if style_name == default_style and type(branch.bright) == "table" then
    palette_bright = copy_palette(branch.bright)
  elseif style_name ~= default_style and type(branch.bright) == "table" and branch.bright ~= style_branch then
    palette_bright = copy_palette(branch.bright)
  end

  if not palette_bright or vim.tbl_isempty(palette_bright) then
    if style_name ~= default_style then
      palette_bright = adjust_palette(style_branch, 0.12)
    else
      palette_bright = copy_palette(style_branch)
    end
  end

  result.normal = palette_normal
  result.bright = palette_bright

  return result
end

function M.available_themes()
  local palette = read_palette_file()
  local themes = {}
  for key, value in pairs(palette) do
    if type(value) == "table" then
      themes[#themes + 1] = key
    end
  end
  table.sort(themes)
  return themes
end

function M.available_styles(theme_name)
  local palette = read_palette_file()
  if not palette or vim.tbl_isempty(palette) then
    return { default_style }
  end

  local branch = palette[theme_name or default_theme]
  if not branch then
    branch = palette[default_theme] or {}
  end

  local styles = {}
  if type(branch.styles) == "table" then
    for key, value in pairs(branch.styles) do
      if type(value) == "table" then
        styles[#styles + 1] = key
      end
    end
  else
    for key, value in pairs(branch) do
      if type(value) == "table" and value.black then
        styles[#styles + 1] = key
      end
    end
  end

  if #styles == 0 then
    styles[1] = default_style
  else
    table.sort(styles)
  end

  return styles
end

return M
