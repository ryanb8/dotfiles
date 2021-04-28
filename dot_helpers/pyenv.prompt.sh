
function pyenv_prompt_update() {
    if command -v pyenv >/dev/null; then
        PYENV_VER=$(pyenv version-name)                                       # capture version name in variable
        if [[ "${PYENV_VER}" != "$(pyenv global | paste -sd ':' -)" ]]; then  # MODIFIED: "system" -> "$(pyenv global | paste -sd ':' -)"
            echo -n "(${PYENV_VER%%:*})|"                        # grab text prior to first ':' character
        else
            echo -n ""
        fi
    else
        echo -n ""
    fi
}

PROMPT_COMMAND="pyenv_prompt_update;$PROMPT_COMMAND"