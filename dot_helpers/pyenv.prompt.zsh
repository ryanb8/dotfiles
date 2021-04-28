
function pyenv_prompt_update() {
    PYENV_PROMPT=""
    if command -v pyenv >/dev/null; then
        PYENV_VER=$(pyenv version-name)                                       # capture version name in variable
        if [[ "${PYENV_VER}" != "$(pyenv global | paste -sd ':' -)" ]]; then  # MODIFIED: "system" -> "$(pyenv global | paste -sd ':' -)"
            PYENV_PROMPT="(${PYENV_VER%%:*})|"                        # grab text prior to first ':' character
        fi
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd pyenv_prompt_update