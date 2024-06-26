local cmp = require'cmp'
local cmp_comp = require'cmp.config.compare'
require("luasnip.loaders.from_vscode").lazy_load()
-- require'luasnip'.
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local too_long_str = "..."
local hasMove = false
cmp.event:on("menu_closed",
function ()
  hasMove = false
end)

cmp.event:on("menu_opened",
function (tab)
  local window = tab.window.entries_win.win
end)

local function confirm_with_and_wo_preselect(fallback)
  if not cmp.confirm({ select = hasMove }) then
    fallback()
  end
end
local function reg_move(move)
  return function(fallback)
    hasMove = true
    move(fallback)
  end
end

vim.cmd([[
set completeopt=menu,menuone,noselect
]])


local function border(hl_name)
  return {
    { "⎧", hl_name },
    { "─", hl_name },
    { "⎫", hl_name },
    { "⎪", hl_name },
    { "⎭", hl_name },
    { "─", hl_name },
    { "⎩", hl_name },
    { "│", hl_name },
  }
end

cmp.setup({
  formatting = {
    format = function(entry, vim_item)
      local begin = vim.fn.match(vim_item.abbr, "(")
      if begin == -1 then
        return vim_item
      end
      if vim_item.abbr:sub(begin + 1, begin + 2) == "()" then
        return vim_item
      end
      vim_item.abbr = string.sub(vim_item.abbr, 1, begin + 1) .. too_long_str .. ")"
      return vim_item
    end,
  },
  completion = {
    completeopt = "menu,menuone,noselect,noinsert",
  },
  preselect = require'cmp.types'.cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered{ border "" },
    documentation = cmp.config.window.bordered{ border "" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(reg_move(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})),
    ["<S-Tab>"] = cmp.mapping(reg_move(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(), -- ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = confirm_with_and_wo_preselect, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lua'},
  },{
    { name = 'neorg'},
    { name = 'nvim_lsp'},
    { name = 'luasnip', option = { use_show_condition = false } }, -- For luasnip users.
  },{
    { name = 'buffer'},
  }),
  sorting = {
    priority_weight = 1,
    comparators = {
      -- cmp.score_offset, -- not good at all
      cmp_comp.exact,
      cmp_comp.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
      cmp_comp.locality,
      cmp_comp.scopes, -- what?
      cmp_comp.length, -- useless 
      cmp_comp.recently_used,
      -- cmp.offset,
      -- cmp.order,
      -- cmp.sort_text,
      -- cmp.kind,
    },
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
