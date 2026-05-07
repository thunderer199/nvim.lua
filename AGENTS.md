**Project structure:**
- `lua/vlad/` — core config: settings, keymaps, autocommands, commands, utilities
- `lua/plugins/` — lazy.nvim plugin specs, one file per concern
- `init.lua` — entry point, only requires `vlad`

**Conventions:**
- Plugin specs: `return { 'name', ... }` — no top-level `require` to preserve lazy loading; configure via `opts` (simple) or `config` (custom)
- Utility modules: `local M = {}; M.fn = fn; return M`
- Keymap definitions should include a `desc` attribute
- LSP servers configured via `vim.lsp.config(name, { ... })` (nvim-lspconfig 1.x API)
- Comments are sparse; only explain non-obvious logic

**Git:**
- Style: conventional commits

**Advising on log output:**
- When the user pastes an error, fix only the error they asked about; mention unrelated warnings in one line at the end, without proposed edits, unless asked.
