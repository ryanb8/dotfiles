### ----
# Local bash_profile before core
####
if [[ -f ~/dotfiles_local/generic_shell_before.sh ]]; then
    source ~/dotfiles_local/generic_shell_before.sh
fi

if [[ -f ~/dotfiles_local/bash_profile_before.sh ]]; then
    source ~/dotfiles_local/bash_profile_before.sh
fi

### ----
# git
### ----
export GIT_EDITOR=vim
source ~/.dot_helpers/git-completion.bash

# setup for git command prompt
green="\[\033[0;32m\]"
blue="\[\033[0;34m\]"
purple="\[\033[0;35m\]"
reset="\[\033[0m\]"
source ~/.dot_helpers/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1

# -------
# Prompt & Terminal;
# -------
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="$purple\u$green\$(__git_ps1)$blue \W $ $reset"
export PS2="| =>"

# add colors to all lines
export CLICOLOR=1
# set LS colors

### ----
# secrets
### ---
echo 'Attempting to read secrets from `~/.secrets`'
if [[ -f ~/.secrets ]]; then
    set -a
    . ~/.secrets
    set +a
else
    echo "No secrets imported - no file ~/.secrets exists"
fi

### ----
# Aliases
### ----
alias ls='ls -Gh'
if [[ "$OSTYPE" == "darwin"* ]]; then
    show_files_on=$(defaults read com.apple.finder AppleShowAllFiles)
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
    if [[ "$show_files_on" != "YES" ]]; then
        echo "Turning show files on for mac"
        echo "This seems inconsistent; may need to be run manually"
        showfiles
    fi
fi

### ----
# bash completions using homebrew
### ----
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

### ----
# Local bash_profile after core
####
if [[ -f ~/dotfiles_local/bash_profile_after.sh ]]; then
    source ~/dotfiles_local/bash_profile_after.sh
fi

if [[ -f ~/dotfiles_local/generic_shell_after.sh ]]; then
    source ~/dotfiles_local/generic_shell_after.sh
fi
