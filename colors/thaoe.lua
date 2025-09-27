if vim.g.colors_name then
  vim.cmd("highlight clear")
end

if vim.fn.has("syntax") == 1 then
  vim.cmd("syntax reset")
end

local ok, thaoe = pcall(require, "thaoe")
if not ok then
  vim.notify("thaoe: unable to require module", vim.log.levels.ERROR)
  return
end

thaoe.load()
