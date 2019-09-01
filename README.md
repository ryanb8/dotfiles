# Overview

These are my core personal dotfiles that are machine (mac/linux) agnostic. They are licensed under MIT.

I use two version controlled repositories to track and manage my dotfiles. The core repository (this one) uses [my fork](https://github.com/ryanb8/dotbot) of [dotbot](https://github.com/anishathalye/dotbot/), provides core shell/R/git/etc. configurations, and is pushed to github. Each machine also has the opportunity for a second, local-only dotfiles repo (located at `~/.local_dotfiles`). This allows for machine specific configurations to be set up as needed.

I keep my secrets (tokens; not like my most embarassing  moment or my greatest fears) in a git-ignored file within my dotfiles repository. My profiles parse and export these secrets as needed.

## Installation

## Licensing

I use [dotbot](https://github.com/anishathalye/dotbot/) to sync/vcs my dotfiles. It is licensed under MIT.
I use both [git-completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) and [git-prompt](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) which are included in the base git distribution, though are user contributed by Shawn Pearce et. al. Git is licensed under GNU General Public License version 2.

## Notes

I don't have any notes here yet.