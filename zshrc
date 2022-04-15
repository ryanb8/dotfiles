# Local profile before core
if [[ -f ~/dotfiles_local/generic_shell_before.sh ]]; then
    source ~/dotfiles_local/generic_shell_before.sh
fi

if [[ -f ~/dotfiles_local/zshrc_before.zsh ]]; then
    source ~/dotfiles_local/zshrc_before.zsh
fi

## lazy load nvm
if [[ ${USE_NVM_LAZY_LOAD-true} == 'true' ]]; then
    export NVM_LAZY_LOAD=true
    export NVM_COMPLETION=true
    source ~/.dotfiles/dot_helpers/zsh-nvm/zsh-nvm.plugin.zsh
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
fpath=(~/.dotfiles/dot_helpers $fpath ~/.dotfiles/dot_helpers/zsh-completions/src ~/.dotfiles/dot_helpers/other-zsh-completions)
function gitstatus_in_git_update() {
    typeset -g GITSTATUS_IN_GIT='|'

    if [ $GITSTATUS_PROMPT_LEN -eq 0 ]; then
        GITSTATUS_IN_GIT=''
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd gitstatus_in_git_update

# Additional Prompt Utils
source ~/dotfiles/dot_helpers/pyenv.prompt.zsh

# Core completion things
autoload -Uz compinit promptinit
compinit
promptinit

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
### Setup fzf:
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
# Completions: - AWS
_aws_zsh_completer_path="$commands[aws_zsh_completer.sh]"
if [[ -r $_aws_zsh_completer_path ]]; then
    pyenv_regex='\.pyenv'
    if [[ "$_aws_zsh_completer_path" =~ .*"$pyenv_regex".* ]]; then
        _aws_zsh_completer_path=$(pyenv prefix)/bin/aws_zsh_completer.sh
    fi
    autoload bashcompinit && bashcompinit
    source $_aws_zsh_completer_path
fi
# Completions: kubectl
if type kubectl  > /dev/null; then
    source <(kubectl completion zsh)
fi
# Missing Completetions:
# Curl
# docker?



### Fish style auto-suggestions
# from: https://github.com/zsh-users/zsh-autosuggestions#configuration
source ~/.dotfiles/dot_helpers/zsh-autosuggestions/zsh-autosuggestions.zsh
# Don't use history sugggestions for cd - it probably doesn't make sense relative
# to the PWD
ZSH_AUTOSUGGEST_HISTORY_IGNORE="(cd *)"
# Don't use Autosuggest for git commands.
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="(git *)"


# Aliases - Platform specific ones are within if blocks
source ~/.dotfiles/dot_helpers/mac_aliases.sh
alias zsh-hotkeys='less ~/.dotfiles/dot_helpers/zsh_dotfiles_functionality.txt'

# Report on hot keys + functionality
echo "Run 'zsh-hotkeys' to see overview of configured functionality + shortcuts"

# My gitstaut prompt has some minor personal adjustments

PROMPT='$PYENV_PROMPT'"%F{13}%n%f|%F{35}%1d%f"'$GITSTATUS_IN_GIT''$GITSTATUS_PROMPT'"➤➤➤ "

# Inject secrets from secrets file
echo 'Attempting to read secrets from `~/.secrets`'
if [[ -f ~/.secrets ]]; then
    set -a
    . ~/.secrets
    set +a
else
    echo "No secrets imported - no file ~/.secrets exists"
fi

# Ensure path is unique (no dupes)
typeset -U PATH path

if [[ -f ~/dotfiles_local/zshrc_after.zsh ]]; then
    source ~/dotfiles_local/zshrc_after.zsh
fi

if [[ -f ~/dotfiles_local/generic_shell_after.sh ]]; then
    source ~/dotfiles_local/generic_shell_after.sh
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

# right arrow or end to accept auto suggestion
# tab to show autocomplete menu, tab/shift-tab to shuffle through to autocomplete options, enter to select and close menu, / to select option and keep menu open for next option
# up arrow to search through past commands - if text is present it will filter past commands based on text,
# ctrl-u cleans entire line
