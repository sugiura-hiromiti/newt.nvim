local util = require 'thaoe.util'

local M = {}

local function mix_for_ui(palette, base, factor)
	local theme_name = palette.theme or 'dark'
	if theme_name == 'light' then
		return util.blend(palette.normal.black, base, factor)
	end
	return util.blend(palette.normal.white, base, factor)
end

local function accent_mix(a, b)
	return util.blend(a, b, 0.5)
end

local function build_groups(palette, opts)
	opts = opts or {}

	local normal = palette.normal or {}
	local bright = palette.bright or {}
	local theme_name = palette.theme or 'dark'
	local is_dark = theme_name ~= 'light'

	-- local bg = normal.black or (is_dark and "#1f2327" or "#ffffff")
	-- local fg = normal.white or (is_dark and "#dcdfe4" or "#202326")
	local bg = is_dark and (normal and normal.black or bright.black) or (normal and normal.white or bright.white)
	local fg = is_dark and (normal and normal.white or bright.white) or (normal and normal.black or bright.black)
	local dim_fg = util.blend(fg, bg, is_dark and 0.8 or 0.2)
	local muted = util.blend(fg, bg, is_dark and 0.6 or 0.35)
	local subtle = util.blend(fg, bg, is_dark and 0.75 or 0.5)
	local border = util.blend(fg, bg, is_dark and 0.25 or 0.75)
	local bg_highlight = mix_for_ui(palette, bg, is_dark and 0.1 or 0.08)
	local bg_selection = util.blend(bright.blue or fg, bg, is_dark and 0.25 or 0.15)
	local bg_float = opts.transparent and nil or mix_for_ui(palette, bg, is_dark and 0.05 or 0.04)
	local virtual_text_bg_alpha = is_dark and 0.1 or 0.08
	local accent_orange = accent_mix(bright.red or fg, bright.yellow or fg)
	local parameter_fg = util.blend(fg, bg, is_dark and 0.6 or 0.35)
	local property_fg = util.blend(fg, bg, is_dark and 0.65 or 0.4)
	local variable_base = fg
	if not is_dark then
		variable_base = bright.blue or bright.magenta or bright.cyan or fg
	end
	local variable_alpha = is_dark and 0.75 or 0.65
	local variable_fg = util.blend(variable_base, bg, variable_alpha)

	local transparent = opts.transparent

	local groups = {
		Normal = { fg = fg, bg = transparent and nil or bg },
		NormalNC = { fg = dim_fg, bg = transparent and nil or bg },
		NormalFloat = { fg = fg, bg = bg_float },
		FloatBorder = { fg = border, bg = bg_float },
		FloatTitle = { fg = bright.blue or fg, bg = bg_float, bold = true },
		WinSeparator = { fg = border, bold = false },
		SignColumn = { fg = subtle, bg = transparent and nil or bg },
		ColorColumn = { bg = mix_for_ui(palette, bg, is_dark and 0.16 or 0.12) },
		Cursor = { fg = bg, bg = fg },
		CursorLine = { bg = mix_for_ui(palette, bg, is_dark and 0.14 or 0.09) },
		CursorColumn = { bg = mix_for_ui(palette, bg, is_dark and 0.14 or 0.09) },
		CursorLineNr = { fg = bright.yellow or fg, bg = transparent and nil or bg, bold = true },
		LineNr = { fg = subtle, bg = transparent and nil or bg },
		VertSplit = { fg = border, bg = transparent and nil or bg },
		FoldColumn = { fg = subtle, bg = transparent and nil or bg },
		Folded = { fg = subtle, bg = mix_for_ui(palette, bg, is_dark and 0.12 or 0.07), italic = true },
		MatchParen = { fg = bright.yellow or fg, bg = bg_selection, bold = true },
		Visual = { bg = bg_selection },
		VisualNOS = { bg = bg_selection },
		Search = { fg = bg, bg = bright.yellow or fg, bold = true },
		IncSearch = { fg = bg, bg = accent_orange, bold = true },
		Substitute = { fg = bg, bg = bright.magenta or fg },
		Pmenu = { fg = fg, bg = bg_highlight },
		PmenuSel = { fg = fg, bg = bg_selection },
		PmenuSbar = { bg = mix_for_ui(palette, bg, is_dark and 0.2 or 0.12) },
		PmenuThumb = { bg = mix_for_ui(palette, bg, is_dark and 0.35 or 0.25) },
		StatusLine = { fg = fg, bg = mix_for_ui(palette, bg, is_dark and 0.2 or 0.12) },
		StatusLineNC = { fg = subtle, bg = mix_for_ui(palette, bg, is_dark and 0.2 or 0.12) },
		TabLine = { fg = subtle, bg = mix_for_ui(palette, bg, is_dark and 0.18 or 0.12) },
		TabLineSel = { fg = fg, bg = bg, bold = true },
		TabLineFill = { bg = mix_for_ui(palette, bg, is_dark and 0.18 or 0.12) },
		Title = { fg = bright.blue or fg, bold = true },
		NonText = { fg = mix_for_ui(palette, bg, is_dark and 0.45 or 0.3) },
		Whitespace = { fg = mix_for_ui(palette, bg, is_dark and 0.45 or 0.3) },
		EndOfBuffer = { fg = transparent and bg or mix_for_ui(palette, bg, is_dark and 0.4 or 0.2) },
		DiffAdd = { fg = bright.green or fg, bg = util.blend(bright.green or fg, bg, is_dark and 0.12 or 0.18) },
		DiffChange = { fg = bright.blue or fg, bg = util.blend(bright.blue or fg, bg, is_dark and 0.12 or 0.18) },
		DiffDelete = { fg = bright.red or fg, bg = util.blend(bright.red or fg, bg, is_dark and 0.12 or 0.18) },
		DiffText = { fg = fg, bg = util.blend(bright.magenta or fg, bg, is_dark and 0.25 or 0.2) },
		SpellBad = { undercurl = true, sp = bright.red or fg },
		SpellCap = { undercurl = true, sp = bright.blue or fg },
		SpellLocal = { undercurl = true, sp = bright.green or fg },
		SpellRare = { undercurl = true, sp = bright.magenta or fg },
		DiagnosticError = { fg = bright.red or fg },
		DiagnosticWarn = { fg = bright.yellow or fg },
		DiagnosticInfo = { fg = bright.blue or fg },
		DiagnosticHint = { fg = bright.cyan or fg },
		DiagnosticOk = { fg = bright.green or fg },
		DiagnosticVirtualTextError = {
			fg = util.blend(bright.red or fg, bg, 0.6),
			bg = util.blend(bright.red or fg, bg, virtual_text_bg_alpha),
		},
		DiagnosticVirtualTextWarn = {
			fg = util.blend(bright.yellow or fg, bg, 0.6),
			bg = util.blend(bright.yellow or fg, bg, virtual_text_bg_alpha),
		},
		DiagnosticVirtualTextInfo = {
			fg = util.blend(bright.blue or fg, bg, 0.6),
			bg = util.blend(bright.blue or fg, bg, virtual_text_bg_alpha),
		},
		DiagnosticVirtualTextHint = {
			fg = util.blend(bright.cyan or fg, bg, 0.6),
			bg = util.blend(bright.cyan or fg, bg, virtual_text_bg_alpha),
		},
		DiagnosticUnderlineError = { undercurl = true, sp = bright.red or fg },
		DiagnosticUnderlineWarn = { undercurl = true, sp = bright.yellow or fg },
		DiagnosticUnderlineInfo = { undercurl = true, sp = bright.blue or fg },
		DiagnosticUnderlineHint = { undercurl = true, sp = bright.cyan or fg },
		DiagnosticSignError = { fg = bright.red or fg, bg = transparent and nil or bg },
		DiagnosticSignWarn = { fg = bright.yellow or fg, bg = transparent and nil or bg },
		DiagnosticSignInfo = { fg = bright.blue or fg, bg = transparent and nil or bg },
		DiagnosticSignHint = { fg = bright.cyan or fg, bg = transparent and nil or bg },
		LspInlayHint = {
			fg = util.blend(fg, bg, is_dark and 0.7 or 0.45),
			bg = util.blend(bright.blue or fg, bg, is_dark and 0.06 or 0.12),
			italic = true,
		},
		LspReferenceText = { bg = util.blend(bright.blue or fg, bg, is_dark and 0.18 or 0.14) },
		LspReferenceRead = { bg = util.blend(bright.cyan or fg, bg, is_dark and 0.18 or 0.14) },
		LspReferenceWrite = { bg = util.blend(bright.magenta or fg, bg, is_dark and 0.18 or 0.14) },
		LspSignatureActiveParameter = {
			fg = bright.yellow or fg,
			bg = util.blend(bright.blue or fg, bg, is_dark and 0.2 or 0.16),
			bold = true,
		},
		ErrorMsg = { fg = bright.red or fg, bold = true },
		WarningMsg = { fg = bright.yellow or fg, bold = true },
		MoreMsg = { fg = bright.green or fg, bold = true },
		ModeMsg = { fg = bright.green or fg, bold = true },
		Question = { fg = bright.green or fg },
		QuickFixLine = { fg = fg, bg = util.blend(bright.yellow or fg, bg, is_dark and 0.18 or 0.14) },
		Todo = { fg = bright.yellow or fg, bg = mix_for_ui(palette, bg, is_dark and 0.22 or 0.16), bold = true },
		debugBreakpoint = { fg = bright.red or fg, bg = util.blend(bright.red or fg, bg, is_dark and 0.2 or 0.16) },
		debugPC = { fg = fg, bg = util.blend(bright.green or fg, bg, is_dark and 0.2 or 0.16) },
		GitSignsAdd = { fg = bright.green or fg },
		GitSignsChange = { fg = bright.blue or fg },
		GitSignsDelete = { fg = bright.red or fg },
		IlluminateWordText = { bg = util.blend(bright.cyan or fg, bg, is_dark and 0.18 or 0.14) },
		IlluminateWordRead = { bg = util.blend(bright.cyan or fg, bg, is_dark and 0.18 or 0.14) },
		IlluminateWordWrite = { bg = util.blend(bright.magenta or fg, bg, is_dark and 0.18 or 0.14) },

		Comment = { fg = muted, italic = true },
		Constant = { fg = bright.cyan or fg },
		String = { fg = bright.green or fg },
		Character = { fg = bright.green or fg },
		Number = { fg = bright.yellow or fg },
		Boolean = { fg = bright.yellow or fg },
		Float = { fg = bright.yellow or fg },
		Identifier = { fg = bright.blue or fg },
		Function = { fg = bright.blue or fg },
		Statement = { fg = bright.magenta or fg },
		Conditional = { fg = bright.magenta or fg },
		Repeat = { fg = bright.magenta or fg },
		Label = { fg = bright.cyan or fg },
		Operator = { fg = bright.cyan or fg },
		Keyword = { fg = bright.magenta or fg, italic = true },
		Exception = { fg = bright.red or fg },
		PreProc = { fg = bright.yellow or fg },
		Include = { fg = bright.cyan or fg },
		Define = { fg = bright.yellow or fg },
		Macro = { fg = bright.yellow or fg },
		PreCondit = { fg = bright.yellow or fg },
		Type = { fg = bright.cyan or fg },
		StorageClass = { fg = bright.yellow or fg },
		Structure = { fg = bright.cyan or fg },
		Typedef = { fg = bright.cyan or fg },
		Special = { fg = bright.magenta or fg },
		SpecialComment = { fg = subtle, italic = true },
		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
	}

	-- Treesitter captures
	groups['@comment'] = { link = 'Comment' }
	groups['@comment.todo'] = { fg = bright.yellow or fg, bold = true }
	groups['@comment.warning'] = { fg = bright.yellow or fg, bold = true }
	groups['@comment.error'] = { fg = bright.red or fg, bold = true }
	groups['@punctuation'] = { fg = subtle }
	groups['@punctuation.bracket'] = { fg = subtle }
	groups['@punctuation.delimiter'] = { fg = subtle }
	groups['@punctuation.special'] = { fg = bright.magenta or fg }
	groups['@constant'] = { link = 'Constant' }
	groups['@constant.builtin'] = { fg = bright.cyan or fg, italic = true }
	groups['@constant.macro'] = { fg = bright.yellow or fg }
	groups['@string'] = { link = 'String' }
	groups['@string.escape'] = { fg = bright.magenta or fg }
	groups['@string.special'] = { fg = bright.cyan or fg }
	groups['@character'] = { fg = bright.green or fg }
	groups['@number'] = { link = 'Number' }
	groups['@boolean'] = { link = 'Boolean' }
	groups['@float'] = { link = 'Float' }
	groups['@function'] = { link = 'Function' }
	groups['@function.builtin'] = { fg = bright.blue or fg, italic = true }
	groups['@function.call'] = { link = 'Function' }
	groups['@function.macro'] = { fg = bright.yellow or fg }
	groups['@keyword'] = { link = 'Keyword' }
	groups['@keyword.function'] = { fg = bright.magenta or fg, italic = true }
	groups['@keyword.operator'] = { link = 'Operator' }
	groups['@keyword.return'] = { link = 'Keyword' }
	groups['@keyword.import'] = { link = 'Include' }
	groups['@keyword.type'] = { link = 'Type' }
	groups['@conditional'] = { link = 'Conditional' }
	groups['@repeat'] = { link = 'Repeat' }
	groups['@label'] = { link = 'Label' }
	groups['@text.reference'] = { fg = bright.blue or fg }
	groups['@text.todo.checked'] = { fg = bright.green or fg }
	groups['@text.todo.unchecked'] = { fg = bright.yellow or fg }
	groups['@markup.heading'] = { link = '@text.title' }
	groups['@markup.strong'] = { bold = true }
	groups['@markup.emphasis'] = { italic = true }
	groups['@markup.link'] = { fg = bright.cyan or fg, underline = true }
	groups['@markup.link.url'] = { fg = bright.cyan or fg, underline = true }
	groups['@markup.link.label'] = { fg = bright.blue or fg }
	groups['@markup.list'] = { fg = bright.yellow or fg }
	groups['@markup.raw'] = { fg = bright.green or fg }
	groups['@markup.quote'] = { fg = subtle, italic = true }
	groups['@string.regex'] = { fg = bright.magenta or fg }
	groups['@string.documentation'] = { fg = muted, italic = true }
	groups['@tag'] = { fg = bright.blue or fg }
	groups['@tag.attribute'] = { fg = bright.yellow or fg }
	groups['@tag.delimiter'] = { fg = subtle }
	groups['@module'] = { fg = bright.blue or fg }
	groups['@module.builtin'] = { fg = bright.blue or fg, italic = true }
	groups['@parameter'] = { fg = parameter_fg }
	groups['@parameter.reference'] = { fg = parameter_fg }
	groups['@method'] = { link = 'Function' }
	groups['@method.call'] = { link = 'Function' }
	groups['@constructor'] = { fg = bright.green or fg }
	groups['@field'] = { fg = property_fg }
	groups['@property'] = { fg = property_fg }
	groups['@variable'] = { fg = variable_fg }
	groups['@variable.builtin'] = { fg = bright.yellow or fg, italic = true }
	groups['@variable.parameter'] = { fg = parameter_fg }
	groups['@type'] = { link = 'Type' }
	groups['@type.builtin'] = { fg = bright.cyan or fg, italic = true }
	groups['@type.definition'] = { link = 'Type' }
	groups['@type.qualifier'] = { link = 'Keyword' }
	groups['@attribute'] = { fg = bright.yellow or fg }
	groups['@property.yaml'] = { fg = property_fg }
	groups['@namespace'] = { fg = bright.blue or fg }
	groups['@symbol'] = { fg = bright.yellow or fg }
	groups['@text'] = { fg = fg }
	groups['@text.title'] = { fg = bright.blue or fg, bold = true }
	groups['@text.literal'] = { fg = bright.green or fg }
	groups['@text.strong'] = { bold = true }
	groups['@text.emphasis'] = { italic = true }
	groups['@text.uri'] = { fg = bright.cyan or fg, underline = true }
	groups['@text.todo'] = { link = 'Todo' }

	groups['@lsp.type.boolean'] = { link = 'Boolean' }
	groups['@lsp.type.comment'] = { link = 'Comment' }
	groups['@lsp.type.enum'] = { link = 'Type' }
	groups['@lsp.type.enumMember'] = { link = 'Constant' }
	groups['@lsp.type.function'] = { link = 'Function' }
	groups['@lsp.type.method'] = { link = 'Function' }
	groups['@lsp.type.namespace'] = { link = '@namespace' }
	groups['@lsp.type.number'] = { link = 'Number' }
	groups['@lsp.type.operator'] = { link = 'Operator' }
	groups['@lsp.type.parameter'] = { link = '@parameter' }
	groups['@lsp.type.property'] = { link = '@property' }
	groups['@lsp.type.string'] = { link = 'String' }
	groups['@lsp.type.type'] = { link = 'Type' }
	groups['@lsp.type.typeParameter'] = { link = '@type' }
	groups['@lsp.type.variable'] = { link = '@variable' }

	return groups
end

function M.compile(palette, opts)
	return build_groups(palette, opts)
end

function M.apply(palette, opts)
	opts = opts or {}
	local groups = build_groups(palette, opts)

	if type(opts.overrides) == 'function' then
		local overridden = opts.overrides(groups, palette)
		if overridden and type(overridden) == 'table' then
			groups = overridden
		end
	elseif type(opts.overrides) == 'table' then
		for name, spec in pairs(opts.overrides) do
			groups[name] = spec
		end
	end

	util.apply_highlights(groups)

	if opts.terminal ~= false then
		util.apply_terminal(palette)
	end

	return groups
end

return M
