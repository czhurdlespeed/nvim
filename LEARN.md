# LEARN.md — a 9-day course for this Neovim setup

A hands-on course to make you fast with *this* config (the `czhurdlespeed` lazy.nvim
setup). Days 1–2 sharpen Vim fundamentals; Days 3–7 cover the plugin stack; Day 8 is
the tmux + Claude Code workflow; Day 9 teaches you to own and extend the config.

Every keymap below is the one actually configured in this repo. Leader is **`Space`**.

---

## How to use this course

- **~1 hour/day**: ~20 min reading/concepts, ~30 min drills, ~10 min applied task.
- **Do the drills in the sandbox** at `learn/` (its own throwaway git repo — break things freely).
  Reset it any time with `git -C learn reset --hard && git -C learn clean -fd`.
- **Discover keys yourself** — your three best tools:
  - Press **`<leader>`** (Space) and pause → **which-key** shows every leader mapping.
  - **`:Lazy`** → what's installed and what each plugin lazy-loads on.
  - **`:checkhealth`**, **`:help <topic>`**, **`:Telescope`-style** `<leader>vh` (help tags via fzf).
- **Keep a real buffer open** while you read; type the keys as you go. Reading ≠ learning.
- Notation: `<C-x>` = Ctrl+x, `<leader>` = Space, `<CR>` = Enter. `n/v/i/x` = the mode.

### Day 0 — run this course inside tmux (5-minute primer)

You'll get the most out of this with nvim and `claude` side by side. Minimum to start:

1. `tmux` to start a session (or just press **`<C-f>`** inside nvim, or **`prefix`+`f`** in tmux,
   to launch **tmux-sessionizer** and fuzzy-pick a project — try the `learn/` folder).
   *(`prefix` is `Ctrl+b` by default.)*
2. Split a pane for Claude Code: **`prefix` then `%`** (vertical) or **`"`** (horizontal), run `claude`.
3. **Move between the nvim pane and the claude pane with `<C-h>` `<C-j>` `<C-k>` `<C-l>`** —
   the same keys move between nvim splits *and* tmux panes (vim-tmux-navigator). This is the
   single most important ergonomic; it's why nvim + Claude in tmux feels seamless.

That's enough to follow along. The full tmux + Claude Code playbook is **Day 8**.

---

## Day 1 — Motion & operator grammar

**Goal:** stop pressing keys repeatedly; start *composing* edits.

**Concepts.** Vim is a language: **`operator` + `count` + `motion/text-object`**. `d2w`
= delete two words; `y$` = yank to end of line; `ci(` = change inside parens. Learn the
motions and the operators compose for free.

- Modes: normal (`Esc`), insert (`i a o`), visual (`v V <C-v>`), command (`:`). In this
  config, **`<C-c>` in insert mode = `Esc`** (faster).
- Word/line motions: `w W b B e ge`, `0 ^ $`, `gg G {count}G`, `f{c} F{c} t{c} T{c} ; ,`.
- Block/screen: `% ` (matching pair), `{ }` (paragraph), `( )` (sentence), `H M L`,
  `zz zt zb` (reposition). This config makes `<C-d>`/`<C-u>` (half-page) **recenter**, and
  `n`/`N` (search) recenter too — so search/scroll keep your eyes in the middle.
- Operators: `d` delete, `c` change, `y` yank, `>` `<` indent, `=` format-indent, `gU`/`gu`
  case. Doubling acts on the line: `dd cc yy`. **`.`** repeats the last change — your most
  powerful key.
- Config remaps to internalize: **`J`** joins lines but keeps the cursor put; in **visual
  mode `J`/`K` move the selection down/up**; **`<leader>s`** starts a substitute of the word
  under the cursor (`:%s/\<word\>/word/gI`).

**Drills (sandbox: `learn/playground/motions.txt`).** Open it: `<C-f>` → pick `learn`, then
`<leader>pf` → `motions.txt`.
1. On the word-motion lines, delete exactly three words with `d3w`, undo `u`, then `c3w` and retype.
2. Use `f, ` then `;` `;` to hop commas on the "Targets here" line; `dt.` to delete up to the period.
3. On the brackets line, put the cursor on a `(` and press `%` to bounce; `ci(` to change all args.
4. `}` `}` to jump paragraphs; `{` back. Try `dap` to delete a whole paragraph, then `u`.
5. Search `target` with `/target<CR>`, cycle with `n`/`N` (watch it recenter), then `*` on a word.
6. Make one edit (e.g. `cwHELLO<Esc>`), move elsewhere, press `.` to repeat it.

**Applied (~10 min).** In any real file you have open: replace every occurrence of a
variable name on screen using `<leader>s` (then edit the replacement and `<CR>`). Then make
the same small fix in three spots using one edit + `.` + `.`.

**Keep warm (rotate daily):** `ciw` · `f{c};` · `%` · `.` · `<leader>s`

**Further reading & watching**
- ThePrimeagen — *Vim As Your Editor* (YouTube playlist): https://www.youtube.com/playlist?list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R
- `vim-be-good` (drill game; install it temporarily to practice motions): https://github.com/ThePrimeagen/vim-be-good
- Built-in: `:help motion.txt`, and run `:Tutor` (vimtutor) for a 30-min guided intro.

---

## Day 2 — Text objects, registers, macros, marks

**Goal:** edit *structures* (a word, a string, a function arg) and automate repetition.

**Concepts.**
- **Text objects** pair with any operator: `i` = inner, `a` = "a"/around.
  `iw aw` (word), `i" a"` (string), `i( i{ i[ a)` (pairs), `ip ap` (paragraph),
  `it at` (HTML/JSX tag). So `ci"` change in quotes, `da(` delete around parens, `yi}` yank
  inside braces, `cit` change inside a tag.
- **This config adds treesitter text objects:** `af`/`if` (a/inner function), `ac`/`ic`
  (class), `aa`/`ia` (parameter/argument). Motions `]m`/`[m` jump to next/prev function,
  `]]`/`[[` to next/prev class. So `dif` deletes a function body; `cia` changes an argument.
- **Visual modes:** `v` char, `V` line, `<C-v>` **block** (column edits — select a column,
  `I`/`A` to insert on every line, `<Esc>`).
- **Registers** (Vim's many clipboards). `"ayy` yanks into register `a`, `"ap` pastes it,
  `"Ayy` appends. Special: `"0` = last yank, `"_` = the black hole (discard). This config:
  - **`clipboard=unnamedplus`** — normal yanks/pastes use the system clipboard already.
  - **`<leader>y` / `<leader>Y`** explicitly yank to the system clipboard (`"+`).
  - **`<leader>d`** deletes into the black hole (doesn't clobber your yank); in visual mode
    **`<leader>p`** pastes over a selection *without* losing what you had yanked.
- **Macros:** `q{reg}` start recording → do edits → `q` stop. Replay with `@{reg}`, repeat
  with `@@`, and `{count}@{reg}` (e.g. `9@a`). Macros are just text in a register, so you can
  paste, fix, and re-yank one (`"ap`, edit, `"ayy`).
- **Marks & jumps:** `` m{a} `` set mark, `` `{a} `` jump to it; `` `` `` jumps to your last
  spot; `<C-o>`/`<C-i>` go back/forward in the **jumplist**.
- **Commenting** is built in (Neovim ≥0.10): `gcc` toggles a line, `gc` + motion (e.g. `gcap`)
  toggles a block, `gc` in visual mode.

**Drills (`learn/playground/objects.ts` and `macros.txt`).**
1. `objects.ts`: `ci"` on the greeting string; `ci(` inside `demo(...)`; `cit` inside the
   `<button>`; `dap` on the comment block; `vi[` then `y` to grab a row of `matrix`.
2. Put the cursor inside `demo`'s body and press `dif` (treesitter "inner function") — gone.
   `u`. Then `]m`/`[m` to hop between `demo` and other functions.
3. `<C-v>` block: select the leading column of the `matrix` rows, `I// <Esc>` to comment them
   column-wise (or use `gc`).
4. `macros.txt` Goal A: on the first name, record `qa` → `I"<Esc>A",<Esc>j` → `q`. Replay with
   `7@a`. Goal B: `=`→`:` swap with a macro. Goal C: prefix lines using `{count}@a`.

**Applied.** Take a repetitive change in a real file (rename a field across a struct, wrap
several lines in quotes) and do it once as a macro, then replay across the rest.

**Keep warm:** `ci"` · `dif` · `<C-v>`+`I` · `qa…q` then `@a` · `gcap`

**Further reading & watching**
- ATIX — *Registers and Macros in Vim*: https://atix.de/en/blog/registers-and-macros-in-vim/
- James Lingford — *Vim macros tip: write it out and yank to register*: https://www.jameslingford.com/blog/vim-macros/
- `nvim-treesitter-textobjects` (the `af/if/ac/ic/aa/ia` provider): https://github.com/nvim-treesitter/nvim-treesitter-textobjects
- Built-in: `:help text-objects`, `:help registers`, `:help recording`.

---

## Day 3 — Moving through files & projects

**Goal:** reach any file/symbol/line in a second or two.

**Concepts.**
- **which-key** is your map: tap **`<leader>`** and wait to see every group (`f` find, `g` git,
  `h` hunk, `r` refactor/rename, `t` test/tab, `x` diagnostics, `z` zen, `d` debug).
- **fzf-lua** (fuzzy finder; all in normal mode):
  - **`<leader>pf`** find files · **`<C-p>`** git files · **`<leader>ps`** live grep (search file *contents*)
  - **`<leader>pws`** grep the word under the cursor · **`<leader>fb`** open buffers ·
    **`<leader>fr`** resume last picker · **`<leader>vh`** help tags
  - **`<leader>fs`** document symbols · **`<leader>fS`** workspace symbols · **`<leader>fd`** diagnostics
  - Inside a picker, the **query syntax** filters fast: `'foo` exact, `^foo` prefix, `foo$`
    suffix, `!foo` negate, space = AND. `<C-q>` sends results to the quickfix list.
- **harpoon** — pin the ≤4 files you're actually working on and teleport between them:
  - **`<leader>a`** add current file · **`<C-e>`** toggle the quick menu (reorder/delete here) ·
    **`<leader>1`…`<leader>4`** jump to pinned file 1–4 · **`<C-S-P>`/`<C-S-N>`** prev/next pinned.
- Other navigation: **`<leader>pv`** file explorer (netrw) · **`<leader>u`** undotree (visualize
  & restore undo history) · quickfix **`<C-k>`/`<C-j>`** next/prev, location list
  **`<leader>k`/`<leader>j`**.

**Drills (sandbox).** From a session rooted at `learn/`:
1. `<leader>pf` and jump to `python/calc.py`. `<leader>a` to harpoon it. Do the same for
   `go/main.go`, `rust/src/main.rs`, `web/src/App.tsx`.
2. Bounce: `<leader>1` … `<leader>4`. Open `<C-e>`, reorder a line, close. Jump again.
3. `<leader>ps` then type `average` — see it across python/go/rust. `<C-q>` to dump to quickfix,
   then `<C-k>`/`<C-j>` to walk results.
4. `<leader>pws` on a function name to grep the project for it. `<leader>fr` to reopen that search.
5. `<leader>u` on a file after a few edits; time-travel your undo tree.

**Applied.** In your real project: harpoon your current 3–4 hot files at the start of a task;
use `<leader>ps` instead of a file tree to find things by content.

**Keep warm:** `<leader>pf` · `<leader>ps` · `<leader>a` · `<leader>1`/`2` · `<C-e>`

**Further reading & watching**
- `harpoon` (harpoon2 branch — the version this config uses): https://github.com/ThePrimeagen/harpoon/tree/harpoon2
- `fzf-lua`: https://github.com/ibhagwan/fzf-lua
- `which-key.nvim`: https://github.com/folke/which-key.nvim

---

## Day 4 — Code intelligence: LSP & completion

**Goal:** navigate and understand code semantically; let completion do the typing.

**Concepts.**
- **Servers are managed by mason.** Run **`:Mason`** to see/install them; **`:checkhealth`**
  to debug. This config auto-installs servers per language (ruff/ty, vtsls, gopls, clangd,
  tailwindcss, cssls, html, eslint, marksman, lua_ls; rust via rustaceanvim).
- **Navigate** (Neovim 0.11 gives several defaults, this config adds fzf-powered ones):
  - **`gd`** definitions · **`gr`** references · **`gi`** implementations (fzf pickers)
  - **`K`** hover docs · **`gO`** document symbols · defaults **`grr`** refs, **`gri`** impl,
    **`grn`** rename, **`gra`** code action (the `gr*` set is built in to 0.11)
  - **`[d`/`]d`** prev/next diagnostic · **`<leader>e`** show the diagnostic float
- **Act:** **`<leader>ca`** code action (quick-fixes, imports, refactors) · **`<leader>rn`** rename symbol.
- **Completion (blink.cmp)** — in insert mode:
  - **`<C-Space>`** open menu / show docs · **`<CR>`** accept · **`<Tab>`/`<S-Tab>`** next/prev
    (also expands/jumps snippets) · **`<C-n>`/`<C-p>`** next/prev · **`<C-e>`** dismiss ·
    **`<C-b>`/`<C-f>`** scroll the docs popup. Signature help shows as you type args.
- **Diagnostics at a glance — trouble.nvim:** **`<leader>xx`** all diagnostics ·
  **`<leader>xd`** buffer diagnostics · **`<leader>xq`** quickfix · **`<leader>xl`** location list ·
  **`<leader>xs`** symbols outline.

**Drills (sandbox).**
1. `python/calc.py`: cursor on the unused `import os` → **`<leader>ca`** → choose the ruff
   fix to remove it. Cursor on `add` → `gr` to see its references (the test). `K` on a function.
2. `gd` on `average` from the test (`python/test_calc.py`) to jump to its definition.
3. **`<leader>rn`** rename `greet` → `salute`; watch the call sites update.
4. `<leader>xd` to list this file's diagnostics; `]d` to walk them; `<leader>e` to read one.
5. In `go/calc.go` start typing `fmt.` and explore blink's menu, docs (`<C-Space>`), `<CR>`.

**Applied.** In your project, navigate a bug with `gd`/`gr` instead of grep; fix an import or
lint nit with `<leader>ca`; rename something real with `<leader>rn`.

**Keep warm:** `gd` · `gr` · `K` · `<leader>ca` · `<leader>rn`

**Further reading & watching**
- Chris Arderne — *Neovim config for 2025* (modern LSP + mason + blink + conform): https://rdrn.me/neovim-2025/
- Stephen Van Tran — *Setting Up LSP Within Neovim (v0.11)*: https://stephenvantran.com/posts/2025-10-29-setup-neovim-lsp-011/
- `blink.cmp`: https://github.com/Saghen/blink.cmp · `mason.nvim`: https://github.com/mason-org/mason.nvim
- Built-in: `:help lsp`, `:help vim.lsp.buf`.

---

## Day 5 — Writing quality code: format, lint, refactor, edit-fu

**Goal:** code stays clean automatically; restructure it safely.

**Concepts.**
- **Formatting — conform.nvim, on save.** Save a buffer and it's formatted: prettierd
  (js/ts/jsx/tsx/css/scss/html/json/yaml/md/mdx/graphql), ruff (python), stylua (lua),
  gofumpt (go), rustfmt (rust), clang-format (c/cpp). **`<leader>f`** formats on demand
  (works on a visual selection too). **CSV is intentionally never reformatted.**
- **Linting.** JS/TS/web is linted by the **ESLint LSP** (with auto-fix on save); `nvim-lint`
  adds shellcheck (sh) and markdownlint (md). Diagnostics show inline + in trouble (`<leader>xx`).
- **Refactoring (refactoring.nvim)** — select code in **visual mode**, then:
  - **`<leader>re`** extract function · **`<leader>rv`** extract variable · **`<leader>ri`**
    inline variable · **`<leader>rr`** menu of available refactors (normal or visual).
- **Edit-fu:**
  - **nvim-surround:** **`ys{motion}{char}`** add surround (e.g. `ysiw"` quote a word),
    **`cs{old}{new}`** change (`cs"'` → swap quotes), **`ds{char}`** delete (`ds(`), and in
    visual mode **`S{char}`** wrap the selection.
  - **autopairs** closes brackets/quotes as you type. **nvim-ts-autotag** closes & renames
    HTML/JSX/TSX tags automatically.
  - **treesitter-context** keeps the enclosing function/class header pinned at the top as you scroll.

**Drills (sandbox).**
1. `python/calc.py` is intentionally mis-spaced (`a+b`). Save (`:w`) and watch ruff format it.
   Try `<leader>f` explicitly too.
2. `web/src/App.tsx` has unsorted Tailwind classes — save and watch them sort (prettierd +
   prettier-plugin-tailwindcss). Rename the `<main>` tag and watch ts-autotag fix the closing tag.
3. Visual-select the loop body in `python/calc.py`'s `average`, **`<leader>re`** to extract a
   function; `u` to undo. Select a literal, **`<leader>rv`** to extract a variable.
4. Surround drills in `playground/objects.ts`: `ysiw"` on a bare word, `cs"'` on a string,
   `ds(` somewhere, and visual-select + `S)`.

**Applied.** Turn on the habit: just `:w` and trust conform. Use `<leader>re` to pull a long
function apart in your real code.

**Keep warm:** `<leader>f` · `ysiw)` · `cs"'` · `<leader>re` (visual) · `gcc`

**Further reading & watching**
- `conform.nvim`: https://github.com/stevearc/conform.nvim · `nvim-lint`: https://github.com/mfussenegger/nvim-lint
- `nvim-surround`: https://github.com/kylechui/nvim-surround
- `refactoring.nvim`: https://github.com/ThePrimeagen/refactoring.nvim

---

## Day 6 — Git, the lazygit way (your primary git tool)

**Goal:** run all of git from the **lazygit** TUI, with gitsigns for quick in-buffer ops.

**Concepts.**
- **lazygit — `<leader>gg`.** A full-screen git TUI. Panels (left, top→bottom): **Status,
  Files, Branches, Commits, Stash**. Jump panels with **`Tab`** / number keys **`1`–`5`**;
  move within a panel with `j/k`. **Press `?` any time for the keybinding menu for your
  version — that's the source of truth.** The everyday keys:
  - **Files:** `Space` stage/unstage the item · `a` stage everything · **`Enter`** to focus a
    file and stage **individual lines/hunks** (`Space` on a line; `v` to range-select) · `d`
    discard · `c` **commit** · `A` amend last commit · `e` edit file.
  - **Branches:** `Space` checkout · `n` new branch · `M` merge into current · `r` rebase
    current onto it · `d` delete.
  - **Commits:** `s` squash into the one below · `f` fixup · `r` reword · `e` start an
    interactive rebase edit · `d` drop · `p` cherry-pick. (This is interactive rebase without
    the raw `git rebase -i` ceremony.)
  - **Stash:** `s` stash changes · on the Stash panel `Space` apply, `g` pop, `d` drop.
  - **Global:** `P` push · `p` pull · `/` search · `+`/`-` resize the diff · `q` quit.
- **gitsigns — in-buffer companion** (don't open lazygit for tiny things):
  - **`]c`/`[c`** jump to next/prev change (hunk) · **`<leader>hp`** preview a hunk ·
    **`<leader>hs`/`<leader>hr`** stage/reset a hunk (works on a visual range too) ·
    **`<leader>hb`** blame this line · **`<leader>gb`** toggle inline blame for the buffer.
- **When to use which:** gitsigns for "stage this hunk / who wrote this line" while editing;
  **lazygit for everything else** — commits, branches, rebases, stashes, pushes, conflicts.
- **fugitive** is also installed (`<leader>gs` opens `:Git`) and great for one-off `:Git`
  commands and `:Git blame`, but lazygit is your default driver here.
- **cloak.nvim** masks secrets: open a `.env`-style file and values render as `****`.

**Drills (sandbox — it's a real, separate git repo).** Open a `learn/` file; you'll see
gitsigns marks on `playground/macros.txt` (it has an uncommitted change).
1. `]c` to jump to the change, `<leader>hp` to preview it, `<leader>hs` to stage just that hunk.
2. `<leader>gg` to open lazygit. In Files, `Enter` a changed file and stage a single line with
   `Space`. Write a commit with `c`.
3. Make two small edits/commits, then in the Commits panel use `s` to **squash** them into one
   (interactive rebase). Reword with `r`.
4. New branch with `n`, switch back with `Space`, stash something with `s` and pop it with `g`.
5. `<leader>hb` on a line to see blame; `<leader>gb` to toggle blame for the whole file.

**Applied.** Adopt the loop: edit → `]c`/`<leader>hp` to review → `<leader>gg` → stage hunks →
commit. Do your next real commit entirely in lazygit.

**Keep warm:** `<leader>gg` · `]c` + `<leader>hp` · `<leader>hs` · (in lazygit) `Space` / `c` / `?`

**Further reading & watching**
- `lazygit`: https://github.com/jesseduffield/lazygit
- Jesse Duffield (lazygit's author) — *15 Lazygit Features In Under 15 Minutes*: https://www.youtube.com/watch?v=CPLdltN7wgE
- `gitsigns.nvim`: https://github.com/lewis6991/gitsigns.nvim

---

## Day 7 — Debug, test, and web dev

**Goal:** step through code, run tests from the editor, and use the web tooling.

**Concepts.**
- **Debugging — nvim-dap** (Python via debugpy, Go via delve, C via codelldb; Rust via
  rustaceanvim):
  - **`<leader>db`** toggle breakpoint · **`<leader>dB`** conditional breakpoint ·
    **`<leader>dc`** start/continue · **`<leader>di`** step into · **`<leader>do`** step over ·
    **`<leader>dO`** step out · **`<leader>dr`** REPL · **`<leader>dl`** run last ·
    **`<leader>du`** toggle the dap UI (scopes/watches/stacks) · **`<leader>dt`** terminate.
- **Testing — neotest:** **`<leader>tr`** run nearest test · **`<leader>tR`** run file ·
  **`<leader>td`** debug nearest (dap) · **`<leader>ts`** toggle the summary tree ·
  **`<leader>to`** open output · **`<leader>tw`** toggle watch mode.
- **Rust — rustaceanvim** (it owns rust-analyzer; no separate config). Commands via
  **`:RustLsp`**: `:RustLsp runnables`, `:RustLsp testables`, `:RustLsp expandMacro`,
  `:RustLsp openCargo`, plus hover actions.
- **Web dev:** Tailwind class **completion** + hover (type inside `className="…"`); **emmet**
  expansion (type `div.card>ul>li*3` and trigger completion); **nvim-ts-autotag** closes/renames
  JSX tags; **nvim-colorizer** shows color swatches in CSS/JSX; **render-markdown** styles
  `.md`/`.mdx` in-buffer (`:RenderMarkdown toggle`).

**Drills (sandbox).**
1. **Go debug:** open `go/main.go`, `<leader>db` on the `avg := Average(nums)` line, `<leader>dc`
   to launch, `<leader>du` for the UI, `<leader>do` to step. Inspect `avg` (it's wrong).
2. **Test → fail → fix:** `<leader>ts` open the summary in `go/`. `<leader>tr` on `TestAverage`
   — it fails. Fix the `+1` bug in `go/calc.go`, save, `<leader>tr` again — green. Repeat in
   `python/` and `rust/src/main.rs`.
3. **Rust:** in `rust/src/main.rs`, cursor on `println!`, `:RustLsp expandMacro`. Use
   `:RustLsp runnables` to run the binary.
4. **C debug:** in `learn/c`, `cc -g main.c -o main`, then breakpoint in `sum_to`, `<leader>dc`
   (point it at `./main`), step the loop.
5. **Web:** in `web/src/App.tsx` add a class inside `className=""` and watch Tailwind complete;
   open `web/src/styles.css` and see colorizer swatches; open `markdown/notes.md` to see render-markdown.

**Applied.** Next time you'd add a print statement, set a breakpoint instead. Run your project's
tests with `<leader>tr` while you edit (`<leader>tw` watch).

**Keep warm:** `<leader>db` · `<leader>dc` · `<leader>du` · `<leader>tr` · `<leader>ts`

**Further reading & watching**
- Tamerlan — *A Guide to Debugging Code in Neovim* (nvim-dap): https://tamerlan.dev/a-guide-to-debugging-applications-in-neovim/
- `nvim-dap`: https://github.com/mfussenegger/nvim-dap · `neotest`: https://github.com/nvim-neotest/neotest
- `rustaceanvim`: https://github.com/mrcjkb/rustaceanvim · `render-markdown.nvim`: https://github.com/MeanderingProgrammer/render-markdown.nvim

---

## Day 8 — tmux + Claude Code playbook

**Goal:** a fast, persistent terminal workspace where nvim and Claude Code work together.

**Concepts.**
- **tmux mental model:** a *server* holds *sessions*; a session has *windows* (like tabs);
  a window has *panes* (splits). The **prefix** (default `Ctrl+b`) precedes tmux commands.
  Detach with **`prefix d`**; reattach later with **`tmux a`** — your nvim, Claude, and shells
  survive closing the terminal or an SSH drop. This config's `~/.config/tmux/tmux.conf` sets
  truecolor (so tokyonight looks right), a short `escape-time` (snappy nvim), mouse on, and
  vi copy-mode.
- **The recommended layout (one session per project):**
  1. **`<C-f>`** (in nvim) or **`prefix f`** (in tmux) → **tmux-sessionizer** fuzzy-picks a
     project and drops you in a session for it.
  2. nvim in one pane; **`prefix %`** to split a vertical pane and run **`claude`** there;
     optionally another pane for a shell/REPL/tests.
  3. **`<C-h/j/k/l>`** moves between the nvim splits *and* the claude pane seamlessly
     (vim-tmux-navigator) — no prefix needed.
- **Claude Code working techniques:**
  - **The edit→reload loop:** when Claude edits files on disk, nvim auto-reloads them
    (`autoread` + a `checktime` autocmd in `set.lua`); you'll see a "changed on disk" notice.
    **Don't sit on unsaved changes** in a buffer you've asked Claude to edit — save or close it
    first to avoid clobbering. Force a reload with `:checktime` or `:e`.
  - **Review before you trust:** after Claude changes things, review them as **hunks** —
    `]c`/`<leader>hp` in nvim, or open **lazygit (`<leader>gg`)** and stage line-by-line. Commit
    the parts you agree with.
  - **Division of labor:** Claude for multi-file/agentic edits and boilerplate; nvim (motions,
    macros, refactor) for precise local edits. Switch panes, don't context-switch apps.
  - **Feeding context:** give Claude exact paths (grab them with `<leader>pf`/`:pwd`). Use tmux
    **copy-mode** (`prefix [`, move with vi keys, `Space` to start selection, `Enter`/`y` to
    copy) to lift Claude's terminal output into a buffer, or send code the other way.
  - **Long tasks:** let Claude run in its pane while `neotest` watch (`<leader>tw`) re-runs your
    tests in nvim. Scroll/search Claude's output with copy-mode.
  - **Pitfalls:** two editors on one unsaved file = conflicts; if you want nvim to flush buffers
    automatically as you switch away, consider `:set autowriteall` (tradeoff: writes happen
    silently).

**Drills.**
1. `<C-f>` → open the `learn` project. `prefix %`, run `claude` in the new pane. `<C-h>`/`<C-l>`
   between nvim and Claude a few times until it's reflex.
2. Ask Claude (in its pane) to add a comment to `learn/python/calc.py`. Watch nvim reload it.
   Review the change with `]c` + `<leader>hp`, then commit it in lazygit (`<leader>gg`).
3. `prefix d` to detach; `tmux a` to come back — note everything is exactly as you left it.
4. Copy-mode practice: `prefix [`, search Claude's output with `/`, select a line, `y`.

**Applied.** Start your next real task by opening a project session, nvim + Claude panes, and
keep tests on watch. Make Claude's changes land as reviewable commits.

**Keep warm:** `<C-f>` · `<C-h>`/`<C-l>` · `prefix %` · `prefix d` / `tmux a` · `<leader>gg` (review)

**Further reading & watching**
- Ham Vocke — *A Quick and Easy Guide to tmux*: https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/
- tmux — *Getting Started* (official wiki): https://github.com/tmux/tmux/wiki/Getting-Started
- `vim-tmux-navigator`: https://github.com/christoomey/vim-tmux-navigator · `tmux-sessionizer`: https://github.com/ThePrimeagen/tmux-sessionizer
- *Why Tmux Users MUST Use The Primeagen's Tmux-sessionizer* (YouTube): https://www.youtube.com/watch?v=f2Y_REbuJek
- linkarzu — *How I replicated ThePrimeagen's developer workflow in macOS*: https://linkarzu.com/posts/macos/prime-workflow/
- Claude Code — *Terminal guide* (official docs): https://code.claude.com/docs/en/terminal-guide · repo: https://github.com/anthropics/claude-code

---

## Day 9 — lazy.nvim & owning your config

**Goal:** understand how the config loads, how plugins work, and confidently change it.

**Concepts.**
- **How lazy.nvim loads this config:**
  - `init.lua` → `require("czhurdlespeed")` → `set` (options/leader) → `remap` (core keys) →
    `lazy_init` (bootstraps lazy.nvim and does `{ import = "czhurdlespeed.lazy" }`).
  - Every file in **`lua/czhurdlespeed/lazy/*.lua`** returns a **plugin spec** (a table); lazy
    merges them all. One concern per file.
  - **`lazy-lock.json`** pins the exact commit of every plugin. **Commit it.** `:Lazy restore`
    re-pins everything to the lockfile; `:Lazy update` bumps + rewrites it.
- **Lazy-loading triggers** (why a plugin isn't loaded until you need it):
  - **`event`** (e.g. `BufReadPre`, `InsertEnter`), **`cmd`** (a command), **`keys`** (a mapping),
    **`ft`** (a filetype), or **`lazy = false`** (load at startup). **`dependencies`** load first;
    **`priority`** orders eager plugins (the colorscheme uses high priority).
  - **`opts` vs `config`:** `opts = {…}` is a table lazy passes to the plugin's `setup()` for you
    — prefer it. `config = function() … end` is when you need custom logic. **`init`** runs at
    startup *before* load (for `vim.g.*` flags).
  - **`build`** runs on install/update (e.g. `:TSUpdate`, `make install_jsregexp`).
  - **Version pinning:** `version = "1.*"`, `branch = "…"`, `tag`, `commit`, `pin = true`. This
    config pins **blink.cmp to v1** (v2 is breaking) and **nvim-treesitter to `master`** (the
    `main` rewrite drops `ensure_installed`).
  - **Two real load-order lessons here:** `mason.nvim` has its own `cmd` so `:Mason` works before
    you open a file; `nvim-treesitter` is `lazy = false` so its `parser/` dir is on the
    runtimepath when other tools look for parsers.
- **How a Neovim plugin is built** (so specs make sense): a plugin is just a directory on the
  **runtimepath** with conventional folders — `lua/` (modules you `require`), `plugin/`
  (auto-sourced once), `ftplugin/` (per-filetype), `after/`, `doc/` (`:help`), and for
  treesitter `queries/`/`parser/`. Most expose **`require("x").setup(opts)`**. Crucially, a
  lazy plugin's directory joins the runtimepath **only when it loads** — that's why a not-yet-
  loaded plugin's commands/parsers seem "missing."
- **lazy.nvim commands:** `:Lazy` (UI), `:Lazy sync` (install+clean+update to match specs),
  `:Lazy install/update/clean/restore`, `:Lazy check`, **`:Lazy profile`** (startup timing),
  `:Lazy log`, `:Lazy health`.

**Drills (modify your own config — best practices).**
1. **Read the machinery:** open `lua/czhurdlespeed/lazy_init.lua`, then `lua/czhurdlespeed/lazy/fzf.lua`
   (a `keys`-loaded spec) and `lua/czhurdlespeed/lazy/colors.lua` (`lazy=false`, `priority=1000`).
   Note how each chooses its trigger.
2. **Add a plugin** (one concern per file): create
   `lua/czhurdlespeed/lazy/todo-comments.lua` returning:
   ```lua
   return {
     {
       "folke/todo-comments.nvim",
       event = { "BufReadPre", "BufNewFile" },
       dependencies = { "nvim-lua/plenary.nvim" },
       opts = {},
     },
   }
   ```
   Then **`:Lazy sync`**, open a file with a `TODO:` comment, and verify it highlights.
   `git add` + commit (including the updated `lazy-lock.json`).
3. **Tweak a mapping/opt:** change a `keys`/`opts` value in a spec and `:so` (or restart).
4. **Profile & inspect:** `:Lazy profile` to see startup cost; `:Lazy` to see why each plugin loaded.
5. **Roll back / remove:** `:Lazy restore` to return to the lockfile; to remove a plugin, delete
   its spec file and `:Lazy clean`.
6. **Sanity check:** run the headless smoke test — `nvim --headless -c "luafile tests/smoke.lua"`.

**Grand capstone (ties the whole week together).** In a tmux project session with Claude in a
side pane: harpoon your hot files (`<leader>a`), find a failing test with `<leader>ps`/`<leader>tr`,
**debug** it (`<leader>db`/`<leader>dc`), **fix** it with LSP + refactor (`<leader>ca`,
`<leader>re`), let it **format on save**, **review hunks** and **commit in lazygit**
(`]c` → `<leader>gg`), and finally **add one small plugin** to your config (drill #2 above) to
prove you can extend the setup yourself.

**Keep warm:** `:Lazy` · `:Lazy sync` · `:Lazy profile` · edit a spec + `:so` · `:checkhealth`

**Further reading & watching**
- `lazy.nvim`: https://github.com/folke/lazy.nvim
- lazy.nvim docs — *Plugin Spec*: https://lazy.folke.io/spec · *Structuring Your Plugins*: https://lazy.folke.io/usage/structuring
- VonHeikemen — *Lazy.nvim: plugin configuration*: https://dev.to/vonheikemen/lazynvim-plugin-configuration-3opi
- Built-in: `:help lazy.nvim.txt`, `:help lua-guide`.

---

## Appendix — Cheatsheet

**Leader is `Space`.** Tap `<leader>` and wait for **which-key** to show everything.

### Motions / objects (built-in)
`w b e` words · `f{c} t{c} ; ,` line-find · `0 ^ $` · `gg G` · `% { } ( )` · `H M L` · `zz`
`d c y` + motion · `dd cc yy` · `.` repeat · `iw aw i" i( ip it` objects
treesitter objects: `af if` func · `ac ic` class · `aa ia` arg · `]m [m` func · `]] [[` class
`gcc` / `gc{motion}` comment · `<C-v>` block · `q{r}…q` / `@{r}` macros · `` m{a} `{a} `` marks

### This config's core remaps
`<leader>s` substitute word · `<leader>y/<leader>Y` system yank · `<leader>d` black-hole delete ·
`x <leader>p` paste-over · `J` join-keep-cursor · visual `J/K` move lines · `<C-d>/<C-u>` centered ·
`<leader>pv` netrw · `<leader><leader>` source file · `<C-c>` = Esc (insert)

### Files / navigation
`<leader>pf` files · `<C-p>` git files · `<leader>ps` grep · `<leader>pws` grep word ·
`<leader>fb` buffers · `<leader>fr` resume · `<leader>fs/<leader>fS` symbols · `<leader>fd` diag ·
`<leader>vh` help · harpoon `<leader>a` add / `<C-e>` menu / `<leader>1-4` jump · `<leader>u` undotree ·
quickfix `<C-k>/<C-j>` · loclist `<leader>k/<leader>j`

### LSP / completion
`gd gr gi` def/refs/impl · `K` hover · `gO` symbols · `grn gra grr gri` (0.11) · `[d ]d` diag ·
`<leader>e` float · `<leader>ca` action · `<leader>rn` rename · trouble `<leader>xx/xd/xq/xl/xs`
blink (insert): `<C-Space>` · `<CR>` · `<Tab>/<S-Tab>` · `<C-n>/<C-p>` · `<C-e>` · `<C-b>/<C-f>`

### Edit / format / refactor
`<leader>f` format · save = format-on-save · surround `ys{m}{c}` `cs{old}{new}` `ds{c}` (visual `S`) ·
refactor (visual) `<leader>re` func · `<leader>rv` var · `<leader>ri` inline · `<leader>rr` menu

### Git
in nvim: `<leader>gg` lazygit · `]c/[c` hunks · `<leader>hp` preview · `<leader>hs/<leader>hr`
stage/reset hunk · `<leader>hb` blame line · `<leader>gb` blame toggle · `<leader>gs` fugitive
inside lazygit: `Tab`/`1-5` panels · `Space` stage · `Enter` stage lines · `c` commit · `A` amend ·
`n` branch · `M` merge · `r` rebase · `s` squash/stash · `P` push · `p` pull · **`?` all keys**

### Debug / test
dap: `<leader>db` bp · `<leader>dB` cond bp · `<leader>dc` continue · `<leader>di/do/dO` step ·
`<leader>dr` repl · `<leader>dl` last · `<leader>du` UI · `<leader>dt` terminate
neotest: `<leader>tr` nearest · `<leader>tR` file · `<leader>td` debug · `<leader>ts` summary ·
`<leader>to` output · `<leader>tw` watch · rust: `:RustLsp runnables|testables|expandMacro`

### tmux
`<C-f>` sessionizer · `<C-h/j/k/l>` move panes (and nvim splits) · `prefix %`/`"` split ·
`prefix d` detach · `tmux a` attach · `prefix [` copy-mode · prefix = `Ctrl+b`

### lazy.nvim
`:Lazy` UI · `:Lazy sync` · `:Lazy update` · `:Lazy restore` (lockfile) · `:Lazy clean` ·
`:Lazy profile` startup · `:Lazy log` · `:Mason` tools · `:checkhealth`

### Where to look when stuck
- A key? Tap `<leader>` (which-key), or `:map`, or read the spec in `lua/czhurdlespeed/lazy/`.
- A plugin not loaded / command missing? `:Lazy` (check its trigger), then open a file or run its cmd.
- LSP/format/tool broken? `:checkhealth`, `:Mason`, `:LspInfo`, `:ConformInfo`, `:messages`.
- The architecture & gotchas? `CLAUDE.md` in this repo. The migration rationale? the same.
