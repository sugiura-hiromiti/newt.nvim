# thaoe.nvim

Modern dual-mode Neovim colorscheme that adapts to `vim.o.background` and lets you pick between *normal* and *bright* palettes derived from the bundled `colors.json`.

## Highlights
- Rich dark and light themes tuned from a single palette source of truth.
- Style switcher (`normal` or `bright`) for higher-contrast sessions.
- Extensive highlight coverage: LSP, diagnostics, Telescope, Treesitter, Git signs, and popular UI plugins.
- Helper API (`require('thaoe').build_palette`) for plugin authors who want direct access to the computed colors.

## Installation
Use your preferred plugin manager. Example for [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "awa/thaoe.nvim",
  config = function()
    require("thaoe").setup()
  end,
}
```

## Usage
Load the colorscheme after setup:

```lua
require("thaoe").setup()
vim.cmd.colorscheme("thaoe")
```

### Configuration
`setup` accepts an options table. All fields are optional.

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `background` | `"dark"` &#124; `"light"` | follows `vim.o.background` | Forces a specific background variant. |
| `style` | `"normal"` &#124; `"bright"` | `"normal"` | Chooses the accent intensity used throughout the theme. |

Example forcing the light bright variant:

```lua
require("thaoe").setup {
  background = "light",
  style = "bright",
}
vim.cmd.colorscheme("thaoe")
```

## Troubleshooting
- `colors.json not found`: ensure the plugin directory (with `colors.json`) is on your runtime path.
- If `:colorscheme thaoe` emits an error, the loader prints a descriptive message via `vim.notify` (or `print` when unavailable).

## License
MIT
