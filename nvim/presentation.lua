-- Requires junegunn/goyo.vim to function properly

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.vpm" },
    callback = function()
        vim.keymap.set("n", "<Left>", ":silent bp<CR> :redraw!<CR><ESC>")
        vim.keymap.set("n", "<Right>", ":silent bn<CR> :redraw!<CR><ESC>")
    end,

})

vim.keymap.set("n", "<leader>pm", function()
    vim.cmd([[Goyo!]])
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
    vim.opt.colorcolumn = "80"
    vim.opt.cmdheight = 2
end, {desc="End Presentation Mode"})

vim.keymap.set("n", "<leader>pM", function()
    vim.cmd([[Goyo 110]])
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.rnu = false
    vim.opt.colorcolumn = "0"
    vim.opt.cmdheight = 0
end, {desc="Begin Presentation Mode"})
