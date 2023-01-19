local cmp = require'cmp'
local cmp_comp = require'cmp.config.compare'

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local too_long_str = "..."

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
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] =  cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ["<S-Tab>"] =  cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(), -- ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm(), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp'},
    { name = 'luasnip'}, -- For luasnip users.
  },{
    { name = 'buffer'},
  }),
  sorting = {
    priority_weight = 0,
    comparators = {
      -- cmp.score_offset, -- not good at all
      cmp_comp.exact,
      cmp_comp.recently_used,
      cmp_comp.locality,
      cmp_comp.scopes, -- what?
      cmp_comp.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
      cmp_comp.length, -- useless 
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

