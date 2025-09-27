local palette = require("thaoe.palette")
local theme = require("thaoe.theme")

local M = {}

local defaults = {
  style = "dark",
  transparent = false,
  terminal = true,
  overrides = nil,
}

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
  return merge_config(user_config, opts)
end

function M.setup(opts)
  if type(opts) ~= "table" then
    return
  end
  user_config = merge_config(user_config, opts)
end

function M.load(opts)
  local config = resolve_config(opts)
  local style = config.style or defaults.style
  local palette_branch = palette.load(style)

  if not palette_branch or not palette_branch.normal then
    vim.notify("thaoe: unable to load palette; aborting colorscheme", vim.log.levels.ERROR)
    return
  end

  if config.transparent then
    palette_branch.transparent = true
  end

  if palette_branch.style == "light" then
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
  local palette_branch = palette.load(config.style)
  return theme.compile(palette_branch, config)
end

function M.available_styles()
  return palette.available_styles()
end

return M
