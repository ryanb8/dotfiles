# Local profile before core
if [[ -f ~/dotfiles_local/zshrc_before.zsh ]]; then
    source ~/dotfiles_local/zshrc.zsh
fi

# Core things
autoload -Uz compinit promptinit
compinit
promptinit

# Completion Configuration:
# Double tab gives completion menu
zstyle ':completion:*' menu select

# Ensure that keybindings are set
# Allows for using ctrl-a, ctrl-e and others
source ~/.dotfiles/dot_helpers/zkbd.zsh

# Enable dirstack
# use dirs -v to see recent directories
# use cd -<NUM> to go back to the NUM prior directory
source ~/.dotfiles/dot_helpers/dirs.zsh

# Enable Auto- Rehash
# i.e. find new executables in path automatically
zstyle ':completion:*' rehash true

# Git Setup
export GIT_EDITOR=vim
source ~/.dot_helpers/gitstatus/gitstatus.prompt.zsh

# Aliase - Platform specific ones are within if blocks
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

# # # Allow for key navigation keys
# key[Control-Left]="${terminfo[kLFT5]}"
# key[Control-Right]="${terminfo[kRIT5]}"

# [[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
# [[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# autoload -Uz beginning-of-line end-of-line
# zle -N beginning-of-line
# zle -N end-of-line

# # Cmd-Left
# bindkey "^[[H" beginning-of-line
# # Cmd-Right
# bindkey "^[[F" end-of-line

# # Option-Right
# bindkey '\e\e[C' forward-word
# # Option-Left
# bindkey '\e\e[D' backward-word

# # If you come from bash you might have to change your $PATH.
# # export PATH=$HOME/bin:/usr/local/bin:$PATH

# # Path to your oh-my-zsh installation.
# export ZSH="/Users/rbshipt/.oh-my-zsh"

# # Set name of the theme to load --- if set to "random", it will
# # load a random theme each time oh-my-zsh is loaded, in which case,
# # to know which specific one was loaded, run: echo $RANDOM_THEME
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# #ZSH_THEME="spaceship"
# # ZSH_THEME="robbyrussell"

# # Set list of themes to pick from when loading at random
# # Setting this variable when ZSH_THEME=random will cause zsh to load
# # a theme from this variable instead of looking in $ZSH/themes/
# # If set to an empty array, this variable will have no effect.
# # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# # Uncomment the following line to use case-sensitive completion.
# # CASE_SENSITIVE="true"

# # Uncomment the following line to use hyphen-insensitive completion.
# # Case-sensitive completion must be off. _ and - will be interchangeable.
# # HYPHEN_INSENSITIVE="true"

# # Uncomment the following line to disable bi-weekly auto-update checks.
# # DISABLE_AUTO_UPDATE="true"

# # Uncomment the following line to automatically update without prompting.
# # DISABLE_UPDATE_PROMPT="true"

# # Uncomment the following line to change how often to auto-update (in days).
# # export UPDATE_ZSH_DAYS=13

# # Uncomment the following line if pasting URLs and other text is messed up.
# # DISABLE_MAGIC_FUNCTIONS="true"

# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"

# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"

# # Uncomment the following line to enable command auto-correction.
# # ENABLE_CORRECTION="true"

# # Uncomment the following line to display red dots whilst waiting for completion.
# # COMPLETION_WAITING_DOTS="true"

# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
# # DISABLE_UNTRACKED_FILES_DIRTY="true"

# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # You can set one of the optional three formats:
# # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # or set a custom format using the strftime function format specifications,
# # see 'man strftime' for details.
# # HIST_STAMPS="mm/dd/yyyy"

# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder

# # Which plugins would you like to load?
# # Standard plugins can be found in $ZSH/plugins/
# # Custom plugins may be added to $ZSH_CUSTOM/plugins/
# # Example format: plugins=(rails git textmate ruby lighthouse)
# # Add wisely, as too many plugins slow down shell startup.
# plugins=(
#     #aws
#     colored-man-pages
#     colorize
#     docker
#     emoji
#     git
#     gitfast
#     git-prompt
#     #jsontools
#     #osx
#     )

# ZSH_COLORIZE_TOOL=chroma

# source $ZSH/oh-my-zsh.sh

# # User configuration

# # export MANPATH="/usr/local/man:$MANPATH"

# # You may need to manually set your language environment
# # export LANG=en_US.UTF-8

# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
# #   export EDITOR='vim'
# # else
# #   export EDITOR='mvim'
# # fi

# # Compilation flags
# # export ARCHFLAGS="-arch x86_64"

# # Set personal aliases, overriding those provided by oh-my-zsh libs,
# # plugins, and themes. Aliases can be placed here, though oh-my-zsh
# # users are encouraged to define aliases within the ZSH_CUSTOM folder.
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"