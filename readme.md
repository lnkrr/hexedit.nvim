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

## Usage

Enable/disable hex view:

```
:Hexedit toggle
:Hexedit decode
:Hexedit encode
```

Jump to a specific address:

```
:Hexedit goto 256
:Hexedit goto 0x100
```

## Lua API

```lua
local hexedit = require("hexedit")

hexedit.toggle()
hexedit.decode()
hexedit.encode()

hexedit.goto_offset(0x100)
```

## Options

```lua
require("hexedit").setup({
    xxd = {
        groupsize = 1,
        cols = 16,
        uppercase = true,
    },
    should_open_with_hexedit = function(buffer)
        if vim.bo[buffer].buftype ~= "" then
            return false
        end

        local filename = vim.api.nvim_buf_get_name(buffer)

        if filename == "" then
            return false
        end

        local result = vim.system({
            M.opts.file_exe,
            "--mime-type",
            "-b",
            filename,
        }):wait()

        return not string.find(result.stdout, "text/")
            and not string.find(result.stdout, "inode/")
    end,
    xxd_exe = "xxd",
    file_exe = "file",
    filetype = "hexedit",
})
```
