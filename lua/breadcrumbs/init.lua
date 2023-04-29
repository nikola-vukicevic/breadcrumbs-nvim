-- -----------------------------------------------------------------------------
-- Copyright (c) Nikola Vukićević 2023.
-- -----------------------------------------------------------------------------
local M = { }
-- -----------------------------------------------------------------------------
local MainConfig = {
	icons = {
		[1] =   " " , -- File
		[2] =   " " , -- Module
		[3] =   " " , -- Namespace
		[4] =   " " , -- Package
		[5] =   " " , -- Class
		[6] =   " " , -- Method
		[7] =   " " , -- Property
		[8] =   " " , -- Field
		[9] =   " " , -- Constructor
		[10] =  "練" , -- Enum
		[11] =  "練" , -- Interface
		[12] =  " " , -- Function
		[13] =  " " , -- Variable
		[14] =  " " , -- Constant
		[15] =  " " , -- String
		[16] =  " " , -- Number
		[17] =  "◩ " , -- Boolean
		[18] =  " " , -- Array
		[19] =  " " , -- Object
		[20] =  " " , -- Key
		[21] =  "ﳠ " , -- Null
		[22] =  " " , -- EnumMember
		[23] =  " " , -- Struct
		[24] =  " " , -- Event
		[25] =  " " , -- Operator
		[26] =  " " , -- TypeParameter
		[255] = " " , -- Macro
	},
	highlighting = {
		[1] =   "BreadcrumbsFile" ,           -- File
		[2] =   "BreadcrumbsModule" ,         -- Module
		[3] =   "BreadcrumbsNamespace" ,      -- Namespace
		[4] =   "BreadcrumbsPackage" ,        -- Package
		[5] =   "BreadcrumbsClass" ,          -- Class
		[6] =   "BreadcrumbsMethod" ,         -- Method
		[7] =   "BreadcrumbsProperty" ,       -- Property
		[8] =   "BreadcrumbsField" ,          -- Field
		[9] =   "BreadcrumbsConstructor" ,    -- Constructor
		[10] =  "BreadcrumbsEnum" ,           -- Enum
		[11] =  "BreadcrumbsInterface" ,      -- Interface
		[12] =  "BreadcrumbsFunction" ,       -- Function
		[13] =  "BreadcrumbsVariable" ,       -- Variable
		[14] =  "BreadcrumbsConstant" ,       -- Constant
		[15] =  "BreadcrumbsString" ,         -- String
		[16] =  "BreadcrumbsNumber" ,         -- Number
		[17] =  "BreadcrumbsBoolean" ,        -- Boolean
		[18] =  "BreadcrumbsArray" ,          -- Array
		[19] =  "BreadcrumbsObject" ,         -- Object
		[20] =  "BreadcrumbsKey" ,            -- Key
		[21] =  "BreadcrumbsNull" ,           -- Null
		[22] =  "BreadcrumbsEnumMember" ,     -- EnumMember
		[23] =  "BreadcrumbsStruct" ,         -- Struct
		[24] =  "BreadcrumbsEvent" ,          -- Event
		[25] =  "BreadcrumbsOperator" ,       -- Operator
		[26] =  "BreadcrumbsTypeParameter" ,  -- TypeParameter
		[255] = "BreadcrumbsMacro" ,          -- Macro
	},
	class_hl_normal    = "BreadcrumbsNormal",
	class_hl_separator = "BreadcrumbsSeparator",
	-- separator          = " • ",
	separator          = " ⟩ ",
	-- separator          = " > ",
	separator_char     = "⟩",
	use_icons          = true,
	lualine_refresh    = true,
	-- use_colors         = false,
	use_colors         = true,
	debug_msg          = false,
}
-- -----------------------------------------------------------------------------
function IsUnderCursor(cur, sym)
	local r
	local c = 0
	-- cursor is at least one whole row above the symbol
	if cur.r < sym.r1 + 1 then
		r = false
		c = -1
	-- cursor is at least one whole row below the symbol
	elseif cur.r > (sym.r2 + 1) then
		r = false
		c = 1
	-- document symbol expands over multiple rows and
	-- thecursor is between the first row (not in) and the
	-- last row (not including the first and last rows)
	elseif cur.r > sym.r1 + 1 and cur.r < sym.r2 + 1 then
		r = true
	-- document symbol is in a single row/line and
	-- the cursor is in the same row
	elseif sym.r1 == sym.r2 and cur.r == sym.r1 + 1 then
		r = cur.c >= sym.c1 + 1 and cur.c <= sym.c2 + 1
		if r == false and cur.c < sym.c1 + 1 then
			c = -1
		elseif r == false then
			c = 1
		end
	-- document symbol expands over multiple rows
	-- cursor is in the first row (occupied by the symbol)
	elseif cur.r == sym.r1 + 1 then
		r = cur.c >= sym.c1 + 1
		if r == false then
			c = -1
		end
	-- document symbol expands over multiple rows
	-- curosr is in the last row occupied by the symbol
	elseif cur.r == sym.r2 + 1 then
		r = cur.c <= sym.c2 + 1
		if r == false then
			c = 1
		end
	end
	--
	return { r = r, c = c }
end
-- -----------------------------------------------------------------------------
function GetSymbolCoordinates(sym)
	local range
	--
	if sym.range then
		range = sym.range           -- default
	else
		range = sym.location.range  -- HTML, PHP
	end
	--
	return {
		r1 = range.start.line,
		c1 = range.start.character,
		r2 = range['end'].line,
		c2 = range['end'].character
	}
end
-- -----------------------------------------------------------------------------
function GetCursorCoordinates()
	local coord = vim.fn.getcurpos(0)

	return {
		r = coord[2],
		c = coord[3]
	}
end
-- -----------------------------------------------------------------------------
function AuxWrite_1(result, ctx)
	print("-- ctx:")
	print(vim.inspect(ctx))
	print("-- result:")
	print(vim.inspect(result))
end
--
function AuxWrite_2(result, ctx, i, coord_cur, coord_sym, sym)
	print("-----")
	print(string.format("number of elements: %d", i))
	print(string.format("start [%d, %d]; end [%d, %d]", coord_sym.r1, coord_sym.c1, coord_sym.r2, coord_sym.c2))
	print(string.format("cur [%d, %d]", coord_cur.r, coord_cur.c))
	print(vim.inspect(sym.name))
	print(vim.inspect(sym.detail))
end
-- -----------------------------------------------------------------------------
function FormatSymbolSeparator(depth, config)
	local separator = ""
	--
	if depth > 0 then separator = config.separator end
	if config.use_colors then
		separator = "%#" .. config.class_hl_separator .. "#" .. separator
	end
	--
	return separator
end
-- -----------------------------------------------------------------------------
function FormatSymbolIcon(sym, config)
	local icon = ""
	--
	if config.use_icons  then icon = config.icons[sym.kind] end
	if config.use_colors then
		local icon_hl = config.highlighting[sym.kind]
		icon = "%#" .. icon_hl .. "#" .. icon .. "%*"
	end
	--
	return icon	
end
-- -----------------------------------------------------------------------------
function FormatSymbol(sym, depth)
	local separator = FormatSymbolSeparator(depth, MainConfig)
	local icon      = FormatSymbolIcon(sym, MainConfig)
	return separator ..
	       icon ..
		   "%#" .. MainConfig.class_hl_normal .. "#" ..
		   sym.name
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTMLPrepend(t1, t2)
	t1.first       = t2.first
	t1.contents    = t2.contents .. t1.contents
	t1.match_start = t1.match_start or t2.match_start
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTMLAppend(t1, t2)
	t1.last        = t2.last
	t1.contents    = t1.contents .. t2.contents
	t1.match_start = t1.match_start or t2.match_start
end
-- -----------------------------------------------------------------------------
function StringBeginsWith(str, pat)
	return string.sub(str, 1, #pat) == pat
end
-- -----------------------------------------------------------------------------
function LeftTrimPHP(s)
	-- form the separator string pattern:
	local test = MainConfig.separator
	if MainConfig.use_colors == true then
		test = "%#" .. MainConfig.class_hl_separator .. "#" ..
		       test
	end
	-- check how many spaces at the end:
	local i    = #test
	local corr = 0
	--
	while test:sub(i, i) == ' ' do
		i    = i - 1
		corr = corr + 1
	end
	-- trim, if needed:
	if StringBeginsWith(s, test) then
		return string.sub(s, #test + corr)
	else
		return s
	end
end
-- -----------------------------------------------------------------------------
function FormatOutputPHP(t_new)
	local out = t_new[1].contents
	return LeftTrimPHP(out)
end
-- -----------------------------------------------------------------------------
function FormatOutputHTMLBorderline(t_new)
	local i = 1
	--
	while t_new[i].match_start == false do
		i = i + 1
	end
	--
	if i > #t_new then
		return t_new[1].contents
	else
		return t_new[i].contents
	end
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTML(t_old, n)
	if #t_old == 1 and vim.bo.filetype == "php" then
		return FormatOutputPHP(t_old)
	end
	--
	if #t_old == 1 then return t_old[1].contents end
	--
	local t_new = { }
	table.insert(t_new, t_old[1])
	table.remove(t_old, 1)
	--
	for i = 1, #t_old do
		for j = 1, #t_new do
			if t_new[j].first == t_old[i].last then
				FormatSymbolsHTMLPrepend(t_new[j], t_old[i])
			elseif t_new[j].last == t_old[i].first then
				FormatSymbolsHTMLAppend(t_new[j], t_old[i])
			else
				table.insert(t_new, t_old[i])
			end
		end
	end
	--
	if #t_new == n and n == 2 then
		return FormatOutputHTMLBorderline(t_new)
	end
	--
	if vim.bo.filetype == "php" then
		return FormatOutputPHP(t_new)
	else
		return FormatSymbolsHTML(t_new, #t_new)
	end
end
-- -----------------------------------------------------------------------------
function CheckMatchStart(sym)
	local cur = GetCursorCoordinates()
	-- print(string.format("cur: [%d, %d]", cur.r, cur.c))
	-- print(string.format("sym: [%d, %d]", sym.location.range.start.line, sym.location.range.start.character))
	-- print("----------")
	return cur.r == sym.location.range.start.line      + 1 and
	       cur.c == sym.location.range.start.character + 1
end
-- -----------------------------------------------------------------------------
function ParseTableHTML(list)
	local t_new = { }

	for i = 1, #list do
		-- (icon)? icon + name : name
		local icon = FormatSymbolIcon(list[i], MainConfig)
		local s    = icon ..
		             "%#".. MainConfig.class_hl_normal .. "#" ..
				     list[i].name
		--
		if list[i].name ~= "html" then
			-- (separator)? separator + previous : previous
			local separator = FormatSymbolSeparator(1, MainConfig) -- (depth, config)
			s = separator .. s
		end
		--
		table.insert(t_new, {
			first       = list[i].containerName,
			last        = list[i].name,
			contents    = s,
			match_start = CheckMatchStart(list[i])
		})
	end
	--
	return t_new
end
-- -----------------------------------------------------------------------------
function GetSymbolsWorkerHTML(data, depth)
	local matching = { }
	local d        = #data

	vim.g.lsp_current_symbol = ""

	for i = 1, d do
		local sym         = data[i]
		local coord_sym   = GetSymbolCoordinates(sym)
		local coord_cur   = GetCursorCoordinates()
		local checkSymbol = IsUnderCursor(coord_cur, coord_sym)

		if checkSymbol.r then
			table.insert(matching, sym)
		end
	end
	--
	if #matching < 1 then return end
	--
	local list = ParseTableHTML(matching)
	-- print("----------")
	-- print(vim.inspect(list))
	vim.g.lsp_current_symbol = FormatSymbolsHTML(list, #list)
end
-- -----------------------------------------------------------------------------
function GetSymbolsWorkerBinary(data, depth)
	local d = #data
	local l = 1
	--
	while l <= d do
		local i = math.floor((l + d) / 2)
		local sym         = data[i]
		local coord_sym   = GetSymbolCoordinates(sym)
		local coord_cur   = GetCursorCoordinates()
		local checkSymbol = IsUnderCursor(coord_cur, coord_sym)

		if checkSymbol.r then
			-- AuxWrite_2(result, ctx, i, coord_cur, coord_sym, sym)
			vim.g.lsp_current_symbol = vim.g.lsp_current_symbol .. FormatSymbol(sym, depth)
			-- print(sym.name)
			if sym.children then
				GetSymbolsWorker(sym.children, depth + 1)
			end
			break
		elseif checkSymbol.c == -1 then
			d = i -1
		elseif checkSymbol.c == 1 then
			l = i + 1
		end
	end
end
-- -----------------------------------------------------------------------------
function GetSymbolsWorker(data, depth)
	local d = #data
	-- print("-----")
	for i = 1, d do
		local sym         = data[i]
		local coord_sym   = GetSymbolCoordinates(sym)
		local coord_cur   = GetCursorCoordinates()
		local checkSymbol = IsUnderCursor(coord_cur, coord_sym)

		if checkSymbol.r then
			-- AuxWrite_2(result, ctx, i, coord_cur, coord_sym, sym)
			vim.g.lsp_current_symbol = vim.g.lsp_current_symbol .. FormatSymbol(sym, depth)
			-- print(sym.name)
			if sym.children then
				GetSymbolsWorker(sym.children, depth + 1)
			end
			--
			break
		end
	end
end
-- -----------------------------------------------------------------------------
function GetSymbols(data, depth)
	-- if data == nil or data == "" then return end
	vim.g.lsp_current_symbol = ""
	-- AuxWrite_1(data)
	-- if data[1].containerName ~= nil then
	if vim.bo.filetype == "html" or vim.bo.filetype == "php" then
		GetSymbolsWorkerHTML(data, depth)
	else
		GetSymbolsWorker(data, depth)
	end
	--
	if vim.g.lsp_last_symbol ~= vim.g.lsp_current_symbol then
	   vim.g.lsp_last_symbol  = vim.g.lsp_current_symbol
	end
	--
	if MainConfig.lualine_refresh == true then
		require('lualine').refresh({
			place = {
				'statusline'
			}
		})
	end
end
-- -----------------------------------------------------------------------------
function LoadSymbolsHandler(err, result, ctx, config)
	if not result then return end
	if MainConfig.debug_msg then AuxWrite_1(result, ctx) end
	vim.g.lsp_buf_result = result
	GetSymbols(result, 0)
end
-- -----------------------------------------------------------------------------
M.Load = function()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, LoadSymbolsHandler)
	-- print("It's aliiive!")
	-- print(vim.g.lsp_current_symbol)
end
-- -----------------------------------------------------------------------------
M.Update = function()
	if vim.g.lsp_buf_result == nil or
	   vim.g.lsp_buf_result == "" then
		return
	end
	GetSymbols(vim.g.lsp_buf_result, 0)
end
-- -----------------------------------------------------------------------------
return M
-- -----------------------------------------------------------------------------
