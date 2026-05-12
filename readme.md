# hexedit.nvim

Edit hex with your favorite text editor.

![Preview](assets/preview.gif)

## Installation

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "lnkrr/hexedit.nvim",
    config = function()
        require("hexedit").setup()
    end,
}
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
    { "lnkrr/hexedit.nvim", opts = {} },
}
```

[vim.pack (Neovim 0.12)](https://neovim.io/doc/user/pack.html#vim.pack):

```lua
vim.pack.add({
    { src = 'https://github.com/lnkrr/hexedit.nvim' },
})

require("hexedit").setup()
```

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'lnkrr/hexedit.nvim'
```

```lua
require("hexedit").setup()
```
