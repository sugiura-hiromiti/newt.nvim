local M = {}

local function sanitize_hex(hex)
  vim.validate({ hex = { hex, { "string" } } })
  if hex:sub(1, 1) == "#" then
    hex = hex:sub(2)
  end
  if #hex ~= 6 then
    error(string.format("invalid hex color '%s'", hex))
  end
  return hex
end

local function hex_to_rgb(hex)
  hex = sanitize_hex(hex)
  return {
    tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5, 6), 16),
  }
end

local function rgb_to_hex(rgb)
  return string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
end

local function clamp(value, min, max)
  if value < min then
    return min
  end
  if value > max then
    return max
  end
  return value
end

function M.blend(foreground, background, alpha)
  alpha = clamp(alpha, 0, 1)
  local fg_rgb = hex_to_rgb(foreground)
  local bg_rgb = hex_to_rgb(background)
  local result = {
    clamp(math.floor((alpha * fg_rgb[1]) + ((1 - alpha) * bg_rgb[1]) + 0.5), 0, 255),
    clamp(math.floor((alpha * fg_rgb[2]) + ((1 - alpha) * bg_rgb[2]) + 0.5), 0, 255),
    clamp(math.floor((alpha * fg_rgb[3]) + ((1 - alpha) * bg_rgb[3]) + 0.5), 0, 255),
  }
  return rgb_to_hex(result)
end

function M.lighten(color, amount)
  return M.blend("#ffffff", color, clamp(amount, 0, 1))
end

function M.darken(color, amount)
  return M.blend("#000000", color, clamp(amount, 0, 1))
end

function M.apply_highlights(groups)
  for name, spec in pairs(groups) do
    if spec then
      if spec.link then
        vim.api.nvim_set_hl(0, name, { link = spec.link, default = spec.default or false })
      else
        local opts = {}
        for key, value in pairs(spec) do
          if value ~= nil then
            opts[key] = value
          end
        end
        vim.api.nvim_set_hl(0, name, opts)
      end
    end
  end
end

function M.apply_terminal(palette)
  if not palette or not palette.normal or not palette.bright then
    return
  end

  local normal = palette.normal
  local bright = palette.bright

  vim.g.terminal_color_0 = normal.black
  vim.g.terminal_color_1 = normal.red
  vim.g.terminal_color_2 = normal.green
  vim.g.terminal_color_3 = normal.yellow
  vim.g.terminal_color_4 = normal.blue
  vim.g.terminal_color_5 = normal.magenta
  vim.g.terminal_color_6 = normal.cyan
  vim.g.terminal_color_7 = normal.white

  vim.g.terminal_color_8 = bright.black
  vim.g.terminal_color_9 = bright.red
  vim.g.terminal_color_10 = bright.green
  vim.g.terminal_color_11 = bright.yellow
  vim.g.terminal_color_12 = bright.blue
  vim.g.terminal_color_13 = bright.magenta
  vim.g.terminal_color_14 = bright.cyan
  vim.g.terminal_color_15 = bright.white
end

return M
