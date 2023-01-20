# Tester.nvim

## Getting Started

[Neovim 0.8](https://github.com/neovim/neovim/releases/tag/v0.8.0) or higher is required for `tester.nvim` to work.

### Supported Frameworks

- PHPUnit
- Pytest

### Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'kessejones/tester.nvim' }
```

After installing, you need to initialize `tester.nvim` with the setup function.

For example:

```lua
require("tester").setup()
```

### Key Mappings

```lua
vim.keymap.set('n', '<leader>oo', require('tester').run_current_test, { desc = 'Run the test where the cursor is in scope' })

vim.keymap.set('n', '<leader>oa', require('tester').run_all_tests, { desc = 'Run all tests from current buffer' })
```

## Contributing

All contributions are welcome! Just open a pull request.

Please look at the [Issues](https://github.com/kessejones/tester.nvim/issues) page to see the current backlog, suggestions, and bugs to work.

## License

Distributed under the same terms as Neovim itself.
