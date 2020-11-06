# Local profile before core
if [[ -f ~/dotfiles_local/zshrc_before.zsh ]]; then
    source ~/dotfiles_local/zshrc.zsh
fi

# Ensure that keybindings are set
# Allows for using ctrl-a, ctrl-e and others
source ~/.dotfiles/dot_helpers/zkbd.zsh

# Enable dirstack
# use dirs -v to see recent directories
# use cd -<NUM> to go back to the NUM prior directory
source ~/.dotfiles/dot_helpers/dirs.zsh

# Git Setup
export GIT_EDITOR=vim
source ~/.dotfiles/dot_helpers/gitstatus/gitstatus.prompt.zsh
zstyle ':completion:*:*:git:*' script ~/.dotfiles/dot_helpers/git-completion.bash
fpath=(~/.dotfiles/dot_helpers $fpath)

# Core completion things
autoload -Uz compinit promptinit
compinit
promptinit

# Enable Auto- Rehash
# i.e. find new executables in path automatically
zstyle ':completion:*' rehash true

# Completion Configuration:
# Double tab gives completion menu
zstyle ':completion:*' menu select
# Fish style auto-suggestions
# from: https://github.com/zsh-users/zsh-autosuggestions#configuration
source ~/.dotfiles/dot_helpers/zsh-autosuggestions/zsh-autosuggestions.zsh
# Don't use history sugggestions for cd - it probably doesn't make sense relative
# to the PWD
ZSH_AUTOSUGGEST_HISTORY_IGNORE="(cd *)"
# Don't use Autosuggest for git commands.
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="(git *)"

# Aliases - Platform specific ones are within if blocks
source ~/.dotfiles/dot_helpers/mac_aliases.sh

# My gitstaut prompt has some minor personal adjustments
# TODO: I need to do this still ^^^^
PROMPT="%F{13}%n%f|%F{35}%1d%f"'$GITSTATUS_PROMPT'"  "

# Inject secrets from secrets file
echo 'Attempting to read secrets from `~/.secrets`'
if [[ -f ~/.secrets ]]; then
    . ~/.secrets
else
    echo "No secrets imported - no file ~/.secrets exists"
fi

# Ensure path is unique (no dupes)
typeset -U PATH path

if [[ -f ~/dotfiles_local/zshrc_after.zsh ]]; then
    source ~/dotfiles_local/zshrc_after.zsh
fi

# Fish style syntax highlighting
# from: https://github.com/zsh-users/zsh-syntax-highlighting
# NOTE that this MUST be the last command in the zshrc (techincally the last zle hook)
source ~/.dotfiles/dot_helpers/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fish style search via up and down
# Uses: https://github.com/zsh-users/zsh-history-substring-search
# Must be loaded after highlighting per ^^^
source ~/.dotfiles/dot_helpers/zsh-history-substring-search/zsh-history-substring-search.zsh

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"    history-substring-search-up
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}"  history-substring-search-down
