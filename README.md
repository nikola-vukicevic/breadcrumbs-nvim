# breadcrumbs-nvim

A simple breadcrumbs generator for Nvim.

![Apr29::170222_80](https://user-images.githubusercontent.com/39658013/235310933-048ccff0-270d-4c64-98f0-eeb489ed4abf.png)

For now, it's just a personal project (in beta state), so use at your own risk.

But:

- it works
- it displays colors and icons
- it plays nicely with HTML and PHP
- it's pretty quick

It is intended to be used with Lualine (even though it's not a full blown Lualine component yet).

The output can also be used in other places (more on that in the next section).

(Of course, bug reports are appreciated.)

## Requirements

- Neovim
- LSP server
- [lualine](https://github.com/nvim-lualine/lualine.nvim)
- [Nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## Installation

ATM, setup is not automated, but it isn't hard either:

- There are two exposed methods (`Load` and `Update`), that need to be hooked up to Vim's `CursorMoved` and `InsertLeave` events

```lua
vim.api.nvim_create_autocmd( { "InsertLeave" } , {
	pattern = "*",
	command = "lua require('breadcrumbs').Load()"
})

vim.api.nvim_create_autocmd("CursorMoved" , {
	pattern = "*",
	command = "lua require('breadcrumbs').Update()"
})
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

Also, it uses custom highlighting groups (that need to be added) ....

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

## TODO

- Treesitter 'backend' (backup)
- User config/setup
- Other improvements and possible bug fixes
