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

local ok, newt = pcall(require, 'newt')
if not ok then
	report 'newt.nvim: unable to load core module'
	return
end

local ok_load, err = pcall(newt.load)
if not ok_load then
	report('newt.nvim: failed to load colorscheme — ' .. tostring(err))
end
