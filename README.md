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
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNormal" ,        { bg = boja_breadcrumbs_bg , fg = "#b0b0b0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsSeparator" ,     { bg = boja_breadcrumbs_bg , fg = "#807a74" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsFile" ,          { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsModule" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNamespace" ,     { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsPackage" ,       { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsClass" ,         { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsMethod" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsProperty" ,      { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsField" ,         { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsConstructor" ,   { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEnum" ,          { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsInterface" ,     { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsFunction" ,      { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsVariable" ,      { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsConstant" ,      { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsString" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNumber" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsBoolean" ,       { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsArray" ,         { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsObject" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsKey" ,           { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsNull" ,          { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEnumMember" ,    { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsStruct" ,        { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsEvent" ,         { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsOperator" ,      { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsTypeParameter" , { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
vim.api.nvim_set_hl ( 0 , "BreadcrumbsMacro" ,         { bg = boja_breadcrumbs_bg , fg = "#80a0f0" } )
```

## TODO

- User config/setup
- Other improvements and possible bug fixes
