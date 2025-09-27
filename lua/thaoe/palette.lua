local M = {}

local default_style = "dark"

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

function M.load(style)
  local palette = read_palette_file()
  if not palette or vim.tbl_isempty(palette) then
    return { style = default_style }
  end

  style = style or default_style
  local branch = palette[style]
  if not branch then
    vim.notify(
      string.format("thaoe: unknown style '%s', falling back to '%s'", style, default_style),
      vim.log.levels.WARN
    )
    style = default_style
    branch = palette[style]
  end

  local result = vim.deepcopy(branch)
  result.style = style
  return result
end

function M.available_styles()
  local palette = read_palette_file()
  local styles = {}
  for key, value in pairs(palette) do
    if type(value) == "table" then
      styles[#styles + 1] = key
    end
  end
  table.sort(styles)
  return styles
end

return M
