# Overview

These are my core personal dotfiles that are machine (mac/linux) agnostic. They are licensed under MIT.

I use two version controlled repositories to track and manage my dotfiles. The core repository (this one) uses [my fork](https://github.com/ryanb8/dotbot) of [dotbot](https://github.com/anishathalye/dotbot/), provides core shell/R/git/etc. configurations, and is pushed to github. Each machine also has the opportunity for a second, local-only dotfiles repo (located at `~/dotfiles_local`). This allows for machine specific configurations to be set up as needed.

The files from this repository are symlinked to the key files in my home directory. The files in the `dotfile_local` directory are sourced as needed by the profiles this directory - typically they mainly set paths and other local system things.

I keep my secrets (tokens; not like my most embarassing  moment or my greatest fears) in a git-ignored file within my home directory ("~/.secrets"). My profiles parse and export these secrets as needed.

## Installation

1. In your home directory, run:

  ```sh
  git clone https://github.com/ryanb8/dotfiles.git \
    && cd dotfiles \
    && ./install
  ```
This will not overwrite any existing profiles.

2. If profiles already existed, and you don't want to use the core profiles, then you are done. If you do want to use the core profiles, move/copy the desired content from the old profiles to the newly created `~/dotfiles_local/` folder and the associated scripts (listed belows). Adjust the core profiles to source files if any new files are created. 

Expected files in `dotfile_local`:

- `~/dotfiles_local/bash_profile_after.sh`
- `~/dotfiles_local/zshrc_after.zsh`
- `~/dotfiles_local/bash_profile_before.sh`
- `~/dotfiles_local/zshrc_before.zsh`

## Updating Dotfiles

To update core dotfiles, edit them within the dotfiles git repository. 

## Licensing

I use [dotbot](https://github.com/anishathalye/dotbot/) to sync/vcs my dotfiles. It is licensed under MIT.
I use several packages from the [zsh-users organization](https://github.com/zsh-users); this includes [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search), [zsh-completions](https://github.com/zsh-users/zsh-completions) - they use a variety of licenses: bsd-3, MIT, and the zsh license.
I use [fzf-tab](https://github.com/Aloxaf/fzf-tab) which uses MIT.
I use both [git-completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) and [git-prompt](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) which are included in the base git distribution, though are user contributed by Shawn Pearce et. al. Git is licensed under GNU General Public License version 2.
