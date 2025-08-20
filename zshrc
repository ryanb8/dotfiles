##############################
# Source local before files
##############################
if [[ -f ~/dotfiles_local/generic_shell_before.sh ]]; then
    source ~/dotfiles_local/generic_shell_before.sh
fi

if [[ -f ~/dotfiles_local/zshrc_before.zsh ]]; then
    source ~/dotfiles_local/zshrc_before.zsh
fi

##############################
# Path Tweaks
##############################

# add a local bin folder if needed
mkdir -p "$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin"

# Ensure path is unique (no dupes)
typeset -U PATH path

##############################
# Common tools & Settings
##############################
## FNM setup
if command -v fnm >/dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

## set up direnv
## https://github.com/direnv/direnv
## I prefer this to shawdowenv on my local machine
## I usually clone all my repos to `~/src/<github|gitlab>/<organization>/<repo>` whitelist repos I own and repos owned by any orgs I really trust with something like the following toml in ~/.config/direnv/direnv.toml
## > [whitelist]
## > prefix = ["/Users/ryan/github/src/my-employer", "/Users/ryan/src/github/ryanb8"]
## Otherwise you have to run `direnv allow path/to/directory` for it load that directory's .envrc file - just once
if command -v direnv >/dev/null; then
    eval "$(direnv hook zsh)"
fi

# Homebrew's chruby
[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }

# Ensure that keybindings are set
# Allows for using ctrl-a, ctrl-e and others
source ~/.dotfiles/dot_helpers/zkbd.zsh

# Enable dirstack
# use dirs -v to see recent directories
# use cd -<NUM> to go back to the NUM prior directory
source ~/.dotfiles/dot_helpers/dirs.zsh




##############################
# Git + Prompt Setup
##############################
export GIT_EDITOR=hx
export GPG_TTY=$(tty)
source ~/.dotfiles/dot_helpers/gitstatus/gitstatus.prompt.zsh
mkdir -p ~/.dotfiles/dot_helpers/jit_completion_helpers
fpath=(~/.dotfiles/dot_helpers $fpath ~/.dotfiles/dot_helpers/zsh-completions/src ~/.dotfiles/dot_helpers/other-zsh-completions ~/.dotfiles/dot_helpers/jit_completion_helpers)
function gitstatus_in_git_update() {
    typeset -g GITSTATUS_IN_GIT='|'

    if [ $GITSTATUS_PROMPT_LEN -eq 0 ]; then
        GITSTATUS_IN_GIT=''
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd gitstatus_in_git_update

# TO DELETE???
# # Additional Prompt Utils
# source ~/dotfiles/dot_helpers/pyenv.prompt.zsh

# PROMPT='$PYENV_PROMPT'"%F{13}%n%f|%F{35}%1d%f"'$GITSTATUS_IN_GIT''$GITSTATUS_PROMPT'"➤➤➤ "
PROMPT="%F{13}%n%f|%F{35}%1d%f"'$GITSTATUS_IN_GIT''$GITSTATUS_PROMPT'"➤➤➤ "


##############################
# Completions - General
##############################
# Homebrew installed things may automagically pull in completion scripts
fpath=($fpath $HOMEBREW_PREFIX/share/zsh/site-functions)
autoload -Uz compinit promptinit
compinit

# Enable Auto- Rehash
# i.e. find new executables in path automatically
zstyle ':completion:*' rehash true

### Completion Configuration:
# Colorize LS:
# BSD/MAC support this very differently than linux
# This is a universal solution, BSD/Mac is the LCD.
export LS_COLORS="di=1;32:ln=35:so=36:pi=37;40:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export LSCOLORS="CxfxgxhaBxegedabagacad"
export CLICOLOR=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#source ~/dotfiles/dot_helpers/LS_COLORS/LS_COLORS
# Double tab gives completion menu
zstyle ':completion:*' menu select


##############################
# Completions - Specific Tools
##############################
# fzf
if ! type fzf  > /dev/null; then
    echo "fzf not found - install from https://github.com/junegunn/fzf if desired"
else
    # if the shell is interactive, turn this on
    [[ $- == *i* ]] && source ~/.dotfiles/dot_helpers/fzf-key-bindings.zsh 2> /dev/null
    ### Use fzf for completion menus
    # Must be before zsh-autosuggestions or other
    source ~/.dotfiles/dot_helpers/fzf-tab/fzf-tab.plugin.zsh
    bindkey '^F' toggle-fzf-tab  # Toggel fzf-tab on abd off with ctlr-f
    toggle-fzf-tab   # default to off
    # I want to be able to tab once and have it auto-complete THEN tab opens up fzf stuff
    echo "fzf-tab is set to off - toggle with ctrl-f"
    # zstyle ":completion:*:git-checkout:*" sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    if ! type exa  > /dev/null; then
        echo "exa not found - install from https://github.com/ogham/exa for full fzf functionality"
    else
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    fi
fi

# kubectl
if type kubectl > /dev/null; then
    # echo "Installing kubectl"
    source <(kubectl completion zsh)
fi

# podman
if type podman > /dev/null; then
    # echo "Installing podman"
    mkdir -p "${fpath[1]}/jit_completion_helpers"
    podman_completion_file="${fpath[1]}/jit_completion_helpers/_podman"
    if [[ ! -f "$podman_completion_file" ]]; then
        podman completion -f "$podman_completion_file" zsh
    fi
fi

# uv
if type uv > /dev/null; then
    source <(uv --generate-shell-completion zsh)
fi
if type uvx > /dev/null; then
    source <(uvx --generate-shell-completion zsh)
fi

# fnm
if type fnm > /dev/null; then
    source <(fnm completions --shell zsh)
fi

##############################
# Fish style autosuggestions, highlighting, search
##############################
# from: https://github.com/zsh-users/zsh-autosuggestions#configuration
source ~/.dotfiles/dot_helpers/zsh-autosuggestions/zsh-autosuggestions.zsh
# Don't use history sugggestions for cd - it probably doesn't make sense relative
# to the PWD
ZSH_AUTOSUGGEST_HISTORY_IGNORE="(cd *)"
# Don't use Autosuggest for git commands.
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="(git *)"
# Fish style syntax highlighting
# from: https://github.com/zsh-users/zsh-syntax-highlighting
# NOTE that this MUST be the last command in the zshrc (techincally the last zle hook)
source ~/.dotfiles/dot_helpers/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fish style search via up and down
# Uses: https://github.com/zsh-users/zsh-history-substring-search
# Should be loaded afer syntax-highlighting
source ~/.dotfiles/dot_helpers/zsh-history-substring-search/zsh-history-substring-search.zsh

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"    history-substring-search-up
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}"  history-substring-search-down

# TODO - why are we overriding the keybindings from zkbd.zsh? Are we?

# right arrow or end to accept auto suggestion
# tab to show autocomplete menu, tab/shift-tab to shuffle through to autocomplete options, enter to select and close menu, / to select option and keep menu open for next option
# up arrow to search through past commands - if text is present it will filter past commands based on text,
# ctrl-u cleans entire line

##############################
# Shared Aliases
##############################
# Aliases - Platform specific ones are within if blocks in their files
source ~/.dotfiles/dot_helpers/mac_aliases.sh
alias zsh-hotkeys='less ~/.dotfiles/dot_helpers/zsh_dotfiles_functionality.txt'



##############################
# Report and setup enviornment
##############################
# Report on hot keys + functionality
echo "Run 'zsh-hotkeys' to see overview of configured functionality + shortcuts"


# Inject secrets from secrets file
echo 'Attempting to read secrets from `~/.secrets`'
if [[ -f ~/.secrets ]]; then
    set -a
    . ~/.secrets
    set +a
else
    echo "No secrets imported - no file ~/.secrets exists"
fi


##############################
# Source local after files
##############################

if [[ -f ~/dotfiles_local/zshrc_after.zsh ]]; then
    source ~/dotfiles_local/zshrc_after.zsh
fi

if [[ -f ~/dotfiles_local/generic_shell_after.sh ]]; then
    source ~/dotfiles_local/generic_shell_after.sh
fi

#######
# things that need to be at the VERY end
#######

# Set homebrew envs as needed
# homebrew prepends
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
