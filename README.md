***this plugin is alpha stage of development.***

# newt.nvim

Modern dual-mode Neovim colorscheme that adapts to `vim.o.background` and lets you pick between *normal* and *bright* palettes derived from the bundled `colors.json`.
`newt` stand for *new terminal* theme for Terminal.app introduced from macOS 26

## Highlights

- Rich dark and light themes tuned from a single palette source of truth.
- Style switcher (`normal` or `bright`) for higher-contrast sessions.
- Extensive highlight coverage: LSP, diagnostics, Telescope, Treesitter, Git signs, and popular UI plugins.
- Helper API (`require('newt').build_palette`) for plugin authors who want direct access to the computed colors. (see [documentation](./doc/newt.nvim.txt) for more detail)

## Installation

Use your preferred plugin manager. Example for [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "sugiura-hiromiti/newt.nvim",
  config = function()
    require("newt").setup()
  end,
}
```

## Usage

Load the colorscheme after setup:

```lua
require("newt").setup()
vim.cmd.colorscheme("newt")
```

### Configuration

`setup` accepts an options table. All fields are optional.

| Option       | Type                         | Default                    | Description                                             |
| ------------ | ---------------------------- | -------------------------- | ------------------------------------------------------- |
| `background` | `"dark"` &#124; `"light"`    | follows `vim.o.background` | Forces a specific background variant.                   |
| `style`      | `"normal"` &#124; `"bright"` | `"normal"`                 | Chooses the accent intensity used throughout the theme. |
| `transparent`| `boolean`                    | `false`                    | Leaves base window backgrounds unset (useful with terminal transparency). |

Example forcing the light bright variant:

```lua
require("newt").setup {
  background = "light",
  style = "bright",
}
vim.cmd.colorscheme("newt")
```

## License

MIT
