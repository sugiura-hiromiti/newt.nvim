local M = {}

local config = {
	background = nil,
	style = 'normal',
	transparent = false,
}

local palette_cache

local function read_file(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		error('newt.nvim: unable to read colors.json: ' .. lines)
	end
	if not lines or vim.tbl_isempty(lines) then
		error 'newt.nvim: colors.json is empty'
	end
	return table.concat(lines, '\n')
end

local function decode_palette()
	if palette_cache then
		return palette_cache
	end

	local path = vim.api.nvim_get_runtime_file('colors.json', false)[1]
	if not path then
		error 'newt.nvim: colors.json not found in runtime path'
	end

	local raw = read_file(path)
	local ok, decoded = pcall(function()
		if vim.json and vim.json.decode then
			return vim.json.decode(raw)
		end
		return vim.fn.json_decode(raw)
	end)

	if not ok then
		error('newt.nvim: colors.json could not be decoded: ' .. decoded)
	end

	palette_cache = decoded
	return palette_cache
end

local function sanitize_hex(hex)
	if type(hex) ~= 'string' then
		return '000000'
	end
	local clean = hex:gsub('#', '')
	if #clean == 3 then
		local r, g, b = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
		clean = r .. r .. g .. g .. b .. b
	end
	if #clean ~= 6 then
		return '000000'
	end
	return clean:upper()
end

local function to_rgb(hex)
	local clean = sanitize_hex(hex)
	local r = tonumber(clean:sub(1, 2), 16)
	local g = tonumber(clean:sub(3, 4), 16)
	local b = tonumber(clean:sub(5, 6), 16)
	return r, g, b
end

local function to_hex(r, g, b)
	return string.format('#%02X%02X%02X', r, g, b)
end

local function blend(foreground, background, alpha)
	alpha = math.max(0, math.min(1, alpha or 0.5))
	local fr, fg, fb = to_rgb(foreground)
	local br, bg, bb = to_rgb(background)

	local function channel(f_c, b_c)
		return math.floor((alpha * f_c) + ((1 - alpha) * b_c) + 0.5)
	end

	return to_hex(channel(fr, br), channel(fg, bg), channel(fb, bb))
end

local function build_palette(opts)
	local data = decode_palette()
	local background = opts.background == 'light' and 'light' or 'dark'
	local style = opts.style == 'bright' and 'bright' or 'normal'
	local transparent = opts.transparent and true or false

	local shades = data[background]
	if not shades then
		error('newt.nvim: missing palette for background ' .. background)
	end

	local active = shades[style]
	if not active then
		error('newt.nvim: missing palette for style ' .. style)
	end
	local companion = shades[style == 'bright' and 'normal' or 'bright']

	local base_bg = background == 'light' and companion.white or active.black
	local base_fg = background == 'light' and active.black or active.white

	local float_bg = blend(companion.white, base_bg, background == 'light' and 0.92 or 0.15)
	local gutter = blend(companion.black, base_bg, background == 'light' and 0.32 or 0.65)
	local cursorline = blend(companion.black, base_bg, background == 'light' and 0.12 or 0.4)
	local border = blend(companion.black, base_bg, background == 'light' and 0.35 or 0.72)
	local statusline = blend(companion.black, base_bg, background == 'light' and 0.2 or 0.55)
	local tabline = blend(companion.black, base_bg, background == 'light' and 0.15 or 0.5)
	local menu = blend(companion.white, base_bg, background == 'light' and 0.88 or 0.22)
	local prompt = blend(active.magenta, base_bg, background == 'light' and 0.45 or 0.7)
	local subtle = blend(companion.white, base_bg, background == 'light' and 0.58 or 0.33)
	local muted = blend(companion.black, base_bg, background == 'light' and 0.3 or 0.75)
	local comment = blend(companion.blue, base_bg, background == 'light' and 0.42 or 0.68)

	local visual = blend(active.blue, base_bg, background == 'light' and 0.35 or 0.6)
	local search = blend(active.yellow, base_bg, background == 'light' and 0.5 or 0.65)
	local incsearch = blend(active.red, base_bg, background == 'light' and 0.5 or 0.7)
	local match = blend(active.cyan, base_bg, background == 'light' and 0.45 or 0.7)

	local diff_add = blend(active.green, base_bg, background == 'light' and 0.42 or 0.65)
	local diff_change = blend(active.blue, base_bg, background == 'light' and 0.38 or 0.6)
	local diff_delete = blend(active.red, base_bg, background == 'light' and 0.44 or 0.7)

	return {
		background = background,
		accent = active,
		transparent = transparent,
		companion = companion,
		base = { fg = base_fg, bg = base_bg },
		text = {
			normal = base_fg,
			subtle = subtle,
			muted = muted,
			comment = comment,
		},
		ui = {
			float = float_bg,
			gutter = gutter,
			cursorline = cursorline,
			border = border,
			statusline = statusline,
			tabline = tabline,
			menu = menu,
			prompt = prompt,
		},
		states = {
			visual = visual,
			search = search,
			incsearch = incsearch,
			match = match,
			diff_add = diff_add,
			diff_change = diff_change,
			diff_delete = diff_delete,
		},
		diagnostic = {
			error = active.red,
			warn = active.yellow,
			info = active.blue,
			hint = active.cyan,
		},
	}
end

local function get_effective_opts(opts)
	local background = config.background
	if opts and opts.background ~= nil then
		background = opts.background
	end
	if not background or (background ~= 'light' and background ~= 'dark') then
		background = (vim.o.background == 'light') and 'light' or 'dark'
	end

	local style = config.style
	if opts and opts.style ~= nil then
		style = opts.style
	end
	if style ~= 'bright' then
		style = 'normal'
	end

	local transparent = config.transparent
	if opts and opts.transparent ~= nil then
		transparent = opts.transparent
	end
	transparent = transparent == true

	return {
		background = background,
		style = style,
		transparent = transparent,
	}
end

local function highlight_groups(p)
	local accent = p.accent
	local companion = p.companion
	local text = p.text
	local ui = p.ui
	local states = p.states
	local diag = p.diagnostic
	local base_bg = p.transparent and 'NONE' or p.base.bg

	local float_border = blend(accent.blue, ui.float, 0.6)
	local shadow = blend(companion.black, p.base.bg, p.background == 'light' and 0.22 or 0.78)
	local menu_border = blend(ui.border, ui.menu, 0.6)
	local prompt_border = blend(ui.prompt, ui.menu, 0.55)
	local virtual_bg = blend(ui.cursorline, p.base.bg, p.background == 'light' and 0.3 or 0.7)
	local inlay_hint_fg = blend(text.subtle, text.normal, p.background == 'light' and 0.35 or 0.2)
	local diagnostic_virtual_fg_mix = p.background == 'light' and 0.4 or 0.2
	local diagnostic_virtual_bg_mix = p.background == 'light' and 0.2 or 0.35
	local function diagnostic_virtual(color)
		local fg = blend(color, text.subtle, diagnostic_virtual_fg_mix)
		return {
			fg = fg,
			bg = blend(color, virtual_bg, diagnostic_virtual_bg_mix),
		}
	end

	return {
		Normal = { fg = text.normal, bg = base_bg },
		NormalNC = { fg = text.normal, bg = base_bg },
		EndOfBuffer = { fg = ui.gutter, bg = base_bg },
		Conceal = { fg = text.subtle },
		Cursor = { fg = p.base.bg, bg = text.normal },
		TermCursor = { fg = p.base.bg, bg = text.normal },
		CursorColumn = { bg = ui.cursorline },
		CursorLine = { bg = ui.cursorline },
		CursorLineNr = { fg = accent.yellow, bg = ui.cursorline, bold = true },
		LineNr = { fg = ui.gutter, bg = base_bg },
		SignColumn = { fg = ui.gutter, bg = base_bg },
		FoldColumn = { fg = ui.gutter, bg = base_bg },
		Folded = { fg = text.subtle, bg = blend(ui.cursorline, p.base.bg, 0.6) },
		NonText = { fg = shadow },
		ColorColumn = { bg = ui.cursorline },

		NormalFloat = { fg = text.normal, bg = ui.float },
		FloatBorder = { fg = float_border, bg = ui.float },
		FloatTitle = { fg = accent.blue, bg = ui.float, bold = true },

		Visual = { bg = states.visual },
		VisualNOS = { bg = states.visual },
		Search = { fg = p.base.bg, bg = states.search },
		IncSearch = { fg = p.base.bg, bg = states.incsearch },
		CurSearch = { fg = p.base.bg, bg = states.incsearch, bold = true },
		MatchParen = { fg = accent.cyan, bg = states.match, bold = true },

		Pmenu = { fg = text.normal, bg = ui.menu },
		PmenuSel = { fg = p.base.bg, bg = accent.blue, bold = true },
		PmenuSbar = { bg = blend(ui.menu, p.base.bg, 0.7) },
		PmenuThumb = { bg = blend(ui.menu, companion.black, 0.55) },
		PmenuBorder = { fg = menu_border, bg = ui.menu },

		StatusLine = { fg = text.normal, bg = ui.statusline },
		StatusLineNC = { fg = text.subtle, bg = ui.statusline },
		WinSeparator = { fg = ui.border, bg = base_bg },
		VertSplit = { fg = ui.border },
		TabLine = { fg = text.subtle, bg = ui.tabline },
		TabLineSel = { fg = accent.blue, bg = base_bg, bold = true },
		TabLineFill = { fg = text.subtle, bg = ui.tabline },

		Title = { fg = accent.blue, bold = true },
		Directory = { fg = accent.blue },
		QuickFixLine = { bg = blend(accent.blue, p.base.bg, 0.2) },

		Comment = { fg = text.comment, italic = true },
		SpecialComment = { fg = text.comment, italic = true },
		Todo = { fg = accent.yellow, bold = true },

		Constant = { fg = accent.cyan },
		String = { fg = accent.green },
		Character = { link = 'String' },
		Number = { fg = accent.yellow },
		Float = { link = 'Number' },
		Boolean = { link = 'Number' },

		Identifier = { fg = accent.cyan },
		Function = { fg = accent.blue },

		Statement = { fg = accent.magenta },
		Conditional = { link = 'Statement' },
		Repeat = { link = 'Statement' },
		Label = { fg = accent.magenta },
		Operator = { fg = accent.red },
		Keyword = { fg = accent.magenta },
		Exception = { fg = accent.red, bold = true },

		PreProc = { fg = accent.magenta },
		Include = { link = 'PreProc' },
		Define = { link = 'PreProc' },
		Macro = { link = 'PreProc' },

		Type = { fg = accent.yellow },
		StorageClass = { fg = accent.blue },
		Structure = { fg = accent.cyan },
		Typedef = { link = 'Type' },

		Special = { fg = accent.red },
		SpecialKey = { fg = text.subtle },
		Delimiter = { fg = accent.blue },
		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },

		DiffAdd = { fg = accent.green, bg = states.diff_add },
		DiffChange = { fg = accent.blue, bg = states.diff_change },
		DiffDelete = { fg = accent.red, bg = states.diff_delete },
		DiffText = { fg = accent.yellow, bg = states.diff_change, bold = true },

		DiagnosticError = { fg = diag.error },
		DiagnosticWarn = { fg = diag.warn },
		DiagnosticInfo = { fg = diag.info },
		DiagnosticHint = { fg = diag.hint },
		DiagnosticUnderlineError = { undercurl = true, sp = diag.error },
		DiagnosticUnderlineWarn = { undercurl = true, sp = diag.warn },
		DiagnosticUnderlineInfo = { undercurl = true, sp = diag.info },
		DiagnosticUnderlineHint = { undercurl = true, sp = diag.hint },
		DiagnosticVirtualTextError = diagnostic_virtual(diag.error),
		DiagnosticVirtualTextWarn = diagnostic_virtual(diag.warn),
		DiagnosticVirtualTextInfo = diagnostic_virtual(diag.info),
		DiagnosticVirtualTextHint = diagnostic_virtual(diag.hint),

		LspReferenceText = { bg = states.match },
		LspReferenceRead = { bg = states.match },
		LspReferenceWrite = { bg = states.match },
		LspSignatureActiveParameter = { fg = accent.yellow, bg = states.match },
		LspInlayHint = { fg = inlay_hint_fg, bg = virtual_bg, italic = true },

		Error = { fg = diag.error, bg = blend(diag.error, p.base.bg, 0.15) },
		WarningMsg = { fg = diag.warn },
		MsgArea = { fg = text.normal, bg = base_bg },
		MsgSeparator = { fg = ui.border, bg = base_bg },
		ModeMsg = { fg = accent.green, bold = true },
		MoreMsg = { fg = accent.green },
		Question = { fg = accent.green },

		SpellBad = { undercurl = true, sp = diag.error },
		SpellCap = { undercurl = true, sp = diag.warn },
		SpellLocal = { undercurl = true, sp = diag.info },
		SpellRare = { undercurl = true, sp = diag.hint },

		GitSignsAdd = { fg = accent.green },
		GitSignsChange = { fg = accent.blue },
		GitSignsDelete = { fg = accent.red },
		GitSignsTopDelete = { fg = accent.red },
		GitSignsChangeDelete = { fg = accent.magenta },

		IndentBlanklineChar = { fg = blend(ui.gutter, p.base.bg, 0.7) },
		IndentBlanklineContextChar = { fg = blend(accent.blue, p.base.bg, 0.4) },
		IndentBlanklineContextStart = { sp = accent.blue, underline = true },

		TelescopeNormal = { fg = text.normal, bg = ui.float },
		TelescopeBorder = { fg = float_border, bg = ui.float },
		TelescopePromptNormal = { fg = text.normal, bg = ui.menu },
		TelescopePromptBorder = { fg = prompt_border, bg = ui.menu },
		TelescopePromptTitle = { fg = p.base.bg, bg = accent.magenta },
		TelescopeResultsTitle = { fg = p.base.bg, bg = accent.blue },
		TelescopePreviewTitle = { fg = p.base.bg, bg = accent.green },
		TelescopeMatching = { fg = accent.yellow, bold = true },

		IlluminatedWordText = { bg = states.match },
		IlluminatedWordRead = { bg = states.match },
		IlluminatedWordWrite = { bg = states.match },

		NavicText = { fg = text.normal },
		NavicSeparator = { fg = text.subtle },
	}
end

local function treesitter_groups(p)
	local accent = p.accent
	local text = p.text
	local companion = p.companion
	local param_fg = blend(accent.yellow, text.normal, p.background == 'light' and 0.58 or 0.42)
	local member_fg = blend(accent.blue, text.normal, p.background == 'light' and 0.5 or 0.35)
	local namespace_fg = blend(accent.blue, text.normal, p.background == 'light' and 0.35 or 0.45)
	local punctuation_fg = blend(companion.black, text.normal, p.background == 'light' and 0.3 or 0.65)

	return {
		['@comment'] = { link = 'Comment' },
		['@comment.todo'] = { link = 'Todo' },
		['@comment.warning'] = { fg = accent.yellow, bold = true },
		['@comment.danger'] = { fg = accent.red, bold = true },

		['@constant'] = { link = 'Constant' },
		['@constant.builtin'] = { fg = accent.yellow, bold = true },
		['@constant.macro'] = { fg = accent.magenta },
		['@symbol'] = { fg = accent.cyan },
		['@string'] = { link = 'String' },
		['@string.escape'] = { fg = accent.red },
		['@string.special'] = { link = 'Special' },
		['@string.regex'] = { fg = accent.yellow },

		['@character'] = { link = 'Character' },
		['@number'] = { link = 'Number' },
		['@float'] = { link = 'Float' },
		['@boolean'] = { link = 'Boolean' },

		['@function'] = { link = 'Function' },
		['@function.builtin'] = { fg = accent.blue, bold = true },
		['@function.call'] = { link = 'Function' },
		['@function.macro'] = { link = 'Macro' },
		['@method'] = { link = 'Function' },
		['@constructor'] = { fg = accent.green },
		['@parameter'] = { fg = param_fg },

		['@keyword'] = { link = 'Keyword' },
		['@keyword.operator'] = { link = 'Operator' },
		['@keyword.function'] = { link = 'Keyword' },
		['@keyword.return'] = { link = 'Keyword' },
		['@conditional'] = { link = 'Conditional' },
		['@repeat'] = { link = 'Repeat' },
		['@label'] = { link = 'Label' },

		['@type'] = { link = 'Type' },
		['@type.builtin'] = { fg = accent.yellow },
		['@type.definition'] = { link = 'Typedef' },
		['@type.qualifier'] = { link = 'Keyword' },

		['@field'] = { fg = member_fg },
		['@property'] = { fg = member_fg },
		['@variable'] = { fg = text.normal },
		['@variable.member'] = { fg = member_fg },
		['@variable.parameter'] = { fg = param_fg },
		['@variable.builtin'] = { fg = accent.yellow, italic = true },

		['@namespace'] = { fg = namespace_fg },
		['@module'] = { fg = namespace_fg },

		['@operator'] = { link = 'Operator' },
		['@punctuation.delimiter'] = { fg = punctuation_fg },
		['@punctuation.bracket'] = { fg = punctuation_fg },
		['@punctuation.special'] = { link = 'Special' },

		['@text'] = { fg = text.normal },
		['@text.strong'] = { bold = true },
		['@text.emphasis'] = { italic = true },
		['@text.underline'] = { underline = true },
		['@text.strike'] = { strikethrough = true },
		['@text.title'] = { link = 'Title' },
		['@text.literal'] = { link = 'String' },
		['@text.uri'] = { fg = accent.blue, underline = true },
		['@text.reference'] = { link = 'Identifier' },
		['@text.note'] = { fg = accent.blue, bold = true },

		['@markup.heading'] = { link = 'Title' },
		['@markup.italic'] = { italic = true },
		['@markup.strike'] = { strikethrough = true },
		['@markup.bold'] = { bold = true },
		['@markup.list'] = { fg = accent.yellow },
		['@markup.link'] = { fg = accent.blue, underline = true },
		['@markup.link.label'] = { fg = accent.cyan },
		['@markup.link.url'] = { fg = accent.blue, underline = true },
		['@markup.raw'] = { link = 'String' },
		['@markup.raw.block'] = { link = 'String' },
		['@markup.quote'] = { fg = text.comment, italic = true },

		['@diff.plus'] = { fg = accent.green },
		['@diff.minus'] = { fg = accent.red },
		['@diff.delta'] = { fg = accent.blue },

		['@tag'] = { fg = accent.magenta },
		['@tag.attribute'] = { fg = accent.green },
		['@tag.delimiter'] = { link = 'Delimiter' },
	}
end

local function apply_highlights(groups)
	for name, spec in pairs(groups) do
		vim.api.nvim_set_hl(0, name, spec)
	end
end

function M.setup(opts)
	opts = opts or {}
	if opts.background ~= nil then
		config.background = opts.background
	end
	if opts.style ~= nil then
		config.style = opts.style
	end
	if opts.transparent ~= nil then
		config.transparent = opts.transparent
	end
end

function M.load(opts)
	local resolved = get_effective_opts(opts)
	local palette = build_palette(resolved)

	vim.o.termguicolors = true
	vim.o.background = resolved.background

	vim.cmd 'highlight clear'
	if vim.fn.exists 'syntax_on' == 1 then
		vim.cmd 'syntax reset'
	end

	vim.g.colors_name = 'newt'

	local groups = highlight_groups(palette)
	for name, spec in pairs(treesitter_groups(palette)) do
		groups[name] = spec
	end

	apply_highlights(groups)

	return palette
end

M.build_palette = build_palette
M.blend = blend

return M
