local notify = vim.notify_once or vim.notify
local log_level = vim.log and vim.log.levels and vim.log.levels.ERROR or nil
local function report(msg)
  if notify then
    if log_level then
      notify(msg, log_level)
    else
      notify(msg)
    end
  else
    print(msg)
  end
end

local ok, thaoe = pcall(require, "thaoe")
if not ok then
  report("thaoe.nvim: unable to load core module")
  return
end

local ok_load, err = pcall(thaoe.load)
if not ok_load then
  report("thaoe.nvim: failed to load colorscheme — " .. tostring(err))
end
