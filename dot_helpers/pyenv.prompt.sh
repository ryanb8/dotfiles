
function pyenv_prompt_update() {
    if command -v pyenv >/dev/null; then
        PYENV_VER=$(pyenv version-name)                                       # capture version name in variable
        if [[ "${PYENV_VER}" != "$(pyenv global | paste -sd ':' -)" ]]; then  # MODIFIED: "system" -> "$(pyenv global | paste -sd ':' -)"
            export PYENV_PROMPT="(${PYENV_VER%%:*}) "                        # grab text prior to first ':' character
        else
            export PYENV_PROMPT=""
        fi
    else
        export PYENV_PROMPT=""
fi
}
