local cmp = require'cmp'

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end
local M = {}

M.max_items = 30
M.too_long_str = "..."

local format = ""

for _=1,M.max_items do
  format = format .. "."
end

cmp.setup({
  formatting = {
    format = function(entry, vim_item)
      local len = string.len(vim_item.abbr)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
      if len > M.max_items then
        vim_item.abbr = string.sub(vim_item.abbr, 1, M.max_items - string.len(M.too_long_str)) .. M.too_long_str
      end
      return vim_item
    end,
  },
  preselect = cmp.PreselectMode.None,
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered{col_offset = -20},
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] =  cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ["<S-Tab>"] =  cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm(), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', group_index = 1, priority = 9 },
    { name = 'luasnip', group_index = 1, priority = 5}, -- For luasnip users.
    { name = 'buffer', group_index = 2, priority = 1 },
  }),
  sorting = {
    priority_weight = 1.0,
    comparators = {
      -- cmp.score_offset, -- not good at all
      cmp.locality,
      cmp.recently_used,
      cmp.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
      cmp.offset,
      cmp.order,
      -- cmp.scopes, -- what?
      -- cmp.sort_text,
      -- cmp.exact,
      -- cmp.kind,
      -- cmp.length, -- useless 
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
