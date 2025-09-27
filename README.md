# thaoe.nvim

A Neovim colorscheme powered directly from the palette stored in [`colors.json`](./colors.json). It ships with both dark and light variants along with opinionated highlight groups for the editor UI, Tree-sitter captures, and built-in LSP diagnostics.

## Features

- Two curated variants (`dark`, `light`) generated from the JSON palette
- Comprehensive highlight coverage for core Vim groups, built-in LSP, and Tree-sitter
- Automatic terminal palette configuration (can be disabled)
- Simple override hooks for custom highlights or plugin integrations

## Installation

Use your favorite plugin manager. Examples:

<details>
<summary>lazy.nvim</summary>

```lua
{
  "sugiura-hiromiti/thaoe.nvim",
  config = function()
    require("thaoe").setup({
      style = "dark",
    })
    vim.cmd.colorscheme("thaoe")
  end,
}
```

</details>

<details>
<summary>packer.nvim</summary>

```lua
use({
  "sugiura-hiromiti/thaoe.nvim",
  config = function()
    require("thaoe").setup({
      style = "dark",
    })
    vim.cmd.colorscheme("thaoe")
  end,
})
```

</details>

After installation, enable the scheme:

```lua
require("thaoe").setup({
  style = "dark", -- or "light"
})
vim.cmd.colorscheme("thaoe")
```

## Configuration

`require("thaoe").setup()` accepts the following options:

| Option        | Type                                    | Default  | Description                                                                                               |
| ------------- | --------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------- |
| `style`       | `"dark" \| "light"`                     | `"dark"` | Select the palette branch from `colors.json`.                                                             |
| `transparent` | `boolean`                               | `false`  | Remove most background fills while preserving contrasts for popups and selections.                        |
| `terminal`    | `boolean`                               | `true`   | Apply the palette to `terminal_color_0..15`.                                                              |
| `overrides`   | `table \| fun(groups, palette): table?` | `nil`    | Adjust or replace highlight groups after generation. Return a table to fully replace the computed groups. |

### Overrides example

```lua
require("thaoe").setup({
  overrides = function(groups, palette)
    groups.Normal.bg = "#10151a"
    groups.DiagnosticVirtualTextError.bg = nil
    -- return the same table (or a brand new one) to apply the changes
    return groups
  end,
})
```

If you prefer declarative overrides, pass a table instead:

```lua
require("thaoe").setup({
  overrides = {
    TelescopeNormal = { fg = "#D9E2E8", bg = "#2F3A42" },
    TelescopeBorder = { fg = "#5CACEA" },
  },
})
```

### Discover available styles

```lua
print(vim.inspect(require("thaoe").available_styles()))
```

## Custom palette

Update `colors.json` to tweak hues. The colorscheme re-reads the file whenever it is required, so edits take effect on the next `:colorscheme thaoe`.

## License

MIT
