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
	-- separator       = " • ",
	separator       = " ⟩ ",
	-- separator       = " > ",
	use_icons       = true,
	lualine_refresh = true,
	use_colors      = false,
	debug_msg       = false,
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
		r = cur.k >= sym.k1 + 1 and cur.k <= sym.k2 + 1
		if r == false and cur.k < sym.k1 + 1 then
			c = -1
		elseif r == false then
			c = 1
		end
	-- document symbol expands over multiple rows
	-- cursor is in the first row (occupied by the symbol)
	elseif cur.r == sym.r1 + 1 then
		r = cur.k >= sym.k1 + 1
		if r == false then
			c = -1
		end
	-- document symbol expands over multiple rows
	-- curosr is in the last row occupied by the symbol
	elseif cur.r == sym.r2 + 1 then
		r = cur.k <= sym.k2 + 1
		if r == false then
			c = 1
		end
	end
	--
	return { r = r, c = c }
end
-- -----------------------------------------------------------------------------
function GetSymbolCoordinates(sym)
	if sym.range then
		return {
			r1 = sym.range.start.line,
			k1 = sym.range.start.character,
			r2 = sym.range['end'].line,
			k2 = sym.range['end'].character
		}
	else
		return {
			r1 = sym.location.range.start.line,
			k1 = sym.location.range.start.character,
			r2 = sym.location.range['end'].line,
			k2 = sym.location.range['end'].character
		}
	end
end
-- -----------------------------------------------------------------------------
function GetCursorCoordinates()
	local coord = vim.fn.getcurpos(0)

	return {
		r = coord[2],
		k = coord[3]
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
	print(string.format("start [%d, %d]; end [%d, %d]", coord_sym.r1, coord_sym.k1, coord_sym.r2, coord_sym.k2))
	print(string.format("cur [%d, %d]", coord_cur.r, coord_cur.k))
	print(vim.inspect(sym.name))
	print(vim.inspect(sym.detail))
end
-- -----------------------------------------------------------------------------
function FormatSymbol(sym, depth)
	local separator = ""
	local icon      = ""
	--
	if depth > 0 then separator = MainConfig.separator end
	--
	if MainConfig.use_icons  then icon = string.format("%s", MainConfig.icons[sym.kind]) end
	if MainConfig.use_colors then icon = "%#Comment" .. icon .. "%*" end
	--
	return string.format("%s%s%s", separator, icon, sym.name)
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTMLPrepend(t1, t2)
	t1.first    = t2.first
	t1.contents = t2.contents .. t1.contents
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTMLAppend(t1, t2)
	t1.last     = t2.last
	t1.contents = t1.contents .. t2.contents
end
-- -----------------------------------------------------------------------------
function FormatSymbolsHTML(t_old)
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
	return FormatSymbolsHTML(t_new)
end
-- -----------------------------------------------------------------------------
function ParseTableHTML(list)
	local t_new = { }

	for i = 1, #list do
		local s = MainConfig.icons[list[i].kind] .. list[i].name
		--
		if list[i].name ~= "html" then
			s = MainConfig.separator .. s
		end
		--
		table.insert(t_new, {
			first    = list[i].containerName,
			last     = list[i].name,
			contents = s
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
	vim.g.lsp_current_symbol = FormatSymbolsHTML(list)
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
		elseif checkSymbol.k == -1 then
			d = i -1
		elseif checkSymbol.k == 1 then
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

