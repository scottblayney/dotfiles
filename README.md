# dotfiles

Personal configuration for bash, Neovim, tmux, vim and starship, installed by symlinking each file into place.

## Quick start

```sh
git clone git@github.com:scottblayney/dotfiles.git
cd dotfiles
./setup
```

Clone it anywhere — `setup` resolves its own location, so there is no path to keep in sync. Restart your shell afterwards, or `source ~/.bashrc`.

To also install the packages in `brewfile`:

```sh
./setup --brew
```

## What's here

| Path | Installs to | What it is |
|---|---|---|
| `bashrc` | `~/.bashrc` | PATH, `EDITOR=vim`, kubectl/flux aliases and completion, starship init |
| `vimrc` | `~/.vimrc` | Plain vim — the distro default with a few tweaks. Unrelated to the Neovim config |
| `tmux.conf` | `~/.tmux.conf` | 1-indexed windows, mouse on, vi copy mode, 25k scrollback, top status bar |
| `starship.toml` | `~/.config/starship.toml` | Prompt: `➜` character, memory usage module, package module off |
| `nvim/` | `~/.config/nvim/` | LazyVim, 32 plugins pinned in `lazy-lock.json` |
| `brewfile` | — | 30 brews, 10 casks, 5 VS Code extensions. Only used with `--brew` |
| `setup` | — | The installer |

`nvim/` is mirrored file by file rather than symlinked as a directory, which keeps Lazy's generated state in `~/.config/nvim` out of the repo. Adding a plugin spec under `nvim/lua/plugins/` needs no change to `setup` — just re-run it.

## How `setup` works

Every installed file is a **symlink** pointing at its copy in this repo, so editing either side edits the same file and `git status` sees it immediately.

- **Idempotent.** A second run reports `0 linked, 13 already current`.
- **Non-destructive.** Anything it would overwrite whose content differs is moved aside to `<file>.bak-<date>` first. Files that already match are replaced silently, since there is nothing to preserve.
- **Survives git.** `git pull`, `git checkout` and branch switches leave the symlinks intact.

```
Usage: ./setup [--dry-run] [--brew]
  -n, --dry-run   show what would change, touch nothing
      --brew      also run 'brew bundle' against ./brewfile
```

Use `--dry-run` first on a machine that already has configs you care about — it prints exactly what would be backed up.

### When you do need to re-run it

- **After moving the repo.** Symlink targets are absolute, so relocating the repo leaves all 13 dangling. Re-run `./setup` from the new location to repoint them.
- **After adding a file** to `nvim/` or to the manifest in `setup`.

Nothing else requires a re-run. This repo previously used hard links, which silently desynced whenever git replaced a file — the home copy kept the old inode and looked fine while no longer tracking the repo. Symlinks have no such failure mode.

## Notes for a new machine

`bashrc` carries a few host-specific lines that assume this setup:

- `. <(flux completion bash)` and the `__start_kubectl` completion expect `flux` and `kubectl` on `PATH`. Without them the shell prints an error on every start.
- It sources `/usr/share/ublue-os/bling/bling.sh`, which only exists on Bluefin / uBlue images. That line is already guarded by a `test -f`.
- A Rancher Desktop block appends `~/.rd/bin` to `PATH` and is marked `DO NOT EDIT` — Rancher Desktop rewrites it.

The prompt needs [starship](https://starship.rs) installed, and a Nerd Font for the glyphs in `starship.toml` and the tmux status bar to render.
