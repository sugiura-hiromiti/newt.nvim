local palette = require("thaoe.palette")
local theme = require("thaoe.theme")

local M = {}

local defaults = {
  theme = "dark",
  style = "normal",
  transparent = false,
  terminal = true,
  overrides = nil,
}

local style_theme_alias_warned = false

local function normalize_options(opts)
  if type(opts) ~= "table" then
    return {}
  end

  local normalized = {}
  for key, value in pairs(opts) do
    if key == "style" and type(value) == "string" then
      if value == "dark" or value == "light" then
        if opts.theme == nil and normalized.theme == nil then
          normalized.theme = value
          if vim and not style_theme_alias_warned then
            style_theme_alias_warned = true
            vim.notify(
              "thaoe: option 'style' now controls palette styles. Treating value '" .. value .. "' as a theme",
              vim.log.levels.WARN
            )
          end
        else
          normalized.style = value
        end
      else
        normalized.style = value
      end
    else
      normalized[key] = value
    end
  end

  if opts.theme ~= nil then
    normalized.theme = opts.theme
  end

  return normalized
end

local function sanitize_config(config)
  if config.theme == nil then
    config.theme = defaults.theme
  end

  if type(config.style) ~= "string" or config.style == "" then
    config.style = defaults.style
  end

  return config
end

local function merge_config(base, extra)
  local result = vim.deepcopy(base)
  if type(extra) ~= "table" then
    return result
  end
  for key, value in pairs(extra) do
    if key == "overrides" then
      result.overrides = value
    elseif type(value) == "table" then
      if type(result[key]) == "table" then
        result[key] = vim.tbl_deep_extend("force", result[key], value)
      else
        result[key] = vim.deepcopy(value)
      end
    else
      result[key] = value
    end
  end
  return result
end

local user_config = vim.deepcopy(defaults)

local function resolve_config(opts)
  local normalized = normalize_options(opts)
  local merged = merge_config(user_config, normalized)
  return sanitize_config(merged)
end

function M.setup(opts)
  if type(opts) ~= "table" then
    return
  end
  local normalized = normalize_options(opts)
  user_config = sanitize_config(merge_config(user_config, normalized))
end

function M.load(opts)
  local config = resolve_config(opts)
  local theme_name = config.theme or defaults.theme
  local style_name = config.style or defaults.style
  local palette_branch = palette.load(theme_name, style_name)

  if not palette_branch or not palette_branch.normal then
    vim.notify("thaoe: unable to load palette; aborting colorscheme", vim.log.levels.ERROR)
    return
  end

  config.style = palette_branch.style or config.style

  if config.transparent then
    palette_branch.transparent = true
  end

  if palette_branch.theme == "light" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end

  if not vim.o.termguicolors then
    vim.o.termguicolors = true
  end

  vim.g.colors_name = "thaoe"

  theme.apply(palette_branch, config)

  return palette_branch
end

function M.compile(opts)
  local config = resolve_config(opts)
  local palette_branch = palette.load(config.theme, config.style)
  config.style = palette_branch.style or config.style
  return theme.compile(palette_branch, config)
end

function M.available_themes()
  return palette.available_themes()
end

function M.available_styles(theme_name)
  return palette.available_styles(theme_name or user_config.theme or defaults.theme)
end

return M
