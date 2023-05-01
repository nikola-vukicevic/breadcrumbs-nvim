# breadcrumbs-nvim

A simple breadcrumbs generator for Nvim.

![Apr29::170222_80](https://user-images.githubusercontent.com/39658013/235310933-048ccff0-270d-4c64-98f0-eeb489ed4abf.png)

For now, it's just a personal project (in beta state), so use at your own risk.

But:

- it works
- it displays colors and icons
- it plays nicely with HTML and PHP
- it's pretty quick

It is intended to be used with Lualine (even though it's not a full blown Lualine component yet), but, the output can also be used in other places (more on that in the next section).

## Requirements

- Neovim
- LSP server
- [lualine](https://github.com/nvim-lualine/lualine.nvim)
- [Nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## Installation

ATM, setup is not automated, but it isn't that hard either:

- There are two exposed methods (`Load` and `Update`), that need to be hooked up to Vim's `CursorMoved` and `InsertLeave` events.

- The `Load` method also needs to be connected with Vim's `CursorHold` method and (more importantly), data structure that stores the locations of various document symbols, needs to be initialized when LSP server starts.

Probably the easiest way to do all of the above, is to add the following lines to the `on_attach` method that gets called when the LSP server starts.

```lua
local on_attach = function(client, bufnr)
	....
	if client.server_capabilities.documentSymbolProvider then
		vim.api.nvim_create_autocmd(
			{
				"InsertLeave",
				"BufEnter",
				"CursorHold"
			} , {
			command = "lua require('breadcrumbs').Load()",
			buffer  = bufnr,
		})
		--
		vim.api.nvim_create_autocmd("CursorMoved" , {
			command = "lua require('breadcrumbs').Update()",
			buffer  = bufnr,
		})
		--
		vim.api.nvim_create_autocmd("BufDelete" , {
			command = "lua require('breadcrumbs').Reset()",
			buffer  = bufnr,
		})
		--
		require('breadcrumbs').Load()
		--
   	end
	....
end
```

The 'breadcrumbs' strings is stored as `g:lsp_current_symbol`, so it is easy to 'pipe' it into Lualine:

```lua
function ReadLSPSymbol()
	if vim.g.lsp_current_symbol == nil then return "" end
	return vim.g.lsp_current_symbol
end

require('lualine').setup {
	...format_bufer_number
	sections = {
		...
		lualine_c = {
			....
			{ ReadLSPSymbol }
			....
		}
		....
	}
}
```

In order for everythong to work properly, custom highlighting groups also need to be set up (example shown below) ....

```lua
vim.api.nvim_set_hl ( 0 , "BreadcrumbsFile" ,          { bg = "#2c323c" , fg = "#7fc29b" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsModule" ,        { bg = "#2c323c" , fg = "#7fc29b" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNamespace" ,     { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsPackage" ,       { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsClass" ,         { bg = "#2c323c" , fg = "#f0a080" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsMethod" ,        { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsProperty" ,      { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsField" ,         { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsConstructor" ,   { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEnum" ,          { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsInterface" ,     { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsFunction" ,      { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsVariable" ,      { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsConstant" ,      { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsString" ,        { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNumber" ,        { bg = "#2c323c" , fg = "#f49fbc" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsBoolean" ,       { bg = "#2c323c" , fg = "#b480f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsArray" ,         { bg = "#2c323c" , fg = "#c0d0f7" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsObject" ,        { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsKey" ,           { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNull" ,          { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEnumMember" ,    { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsStruct" ,        { bg = "#2c323c" , fg = "#f49fbc" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEvent" ,         { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsOperator" ,      { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsTypeParameter" , { bg = "#2c323c" , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsMacro" ,         { bg = "#2c323c" , fg = "#80a0f0" } )
```

## Motivation/rationale

I wanted a very simple plugin that only creates the "breadcrumbs", so I checked out 'the usual suspects'.

With nvim-navic, I somehow couldn't get the highlighting all the way right (there were some minor issues). As for Aerial, there were some issues displaying HTML tags (and also, Aerial is much 'bigger' in scope; the "breadcrums" part is just a side note pretty much).

Those minor bugs were probably much easier to fix than writing a plugin from the ground up (:D), but I decided to bite the bullet and 'be done with it'. :)

## Bugs

ATM, I'm not aware of any major bugs, so - bug reports are very much appreciated. :)

But, there was a bag when opening two or more files of different kinds (i.e. files using different LSP servers), that produced an error message when entering buffer (it was a single message and the plugin kept on working after the message).

Fortunately, I seem to have resolved that bug.

## TODO

- Treesitter 'backend' (backup)
- User config/setup
- Other improvements and possible bug fixes
