#------------------------------------------------------------------------------
# Bash prompt
#
# To see the escape sequences available (such as \W), run `man bash` and then
# search for /^PROMPTING
#
# Color reference: https://misc.flogisoft.com/bash/tip_colors_and_formatting
#------------------------------------------------------------------------------

_my_prompt() {
    local status=$?

    local reset="\[\033[0m\]"
    local bold="\[\033[1m\]"
    local unbold="\[\033[21m\]"
    local dim="\[\033[2m\]"
    local undim="\[\033[22m\]"
    local f_reset="\[\033[39m\]"
    local f_red="\[\033[31m\]"
    local f_green="\[\033[32m\]"
    local f_yellow="\[\033[33m\]"
    local f_blue="\[\033[34m\]"
    local f_pink="\[\033[35m\]"
    local f_cyan="\[\033[36m\]"
    local f_gray="\[\033[38;5;246m\]"

    local sep="${dim}│${undim}"
    local prefix=${MY_PROMPT_PREFIX:-░░}
    local prefix_color=${MY_PROMPT_PREFIX_COLOR:-}
    local prompt=

    # Clock
    prompt="${prompt}${sep}\A"

    # Hostname
    local host=${PROMPT_HOST:-\\h}
    if [ "$host" != '-' ]; then
        prompt="${prompt}${sep}${f_gray}${host}"
    else
        host=''
    fi

    # Status of last command
    if [ $status -ne 0 ]; then
        prompt="${prompt}${sep}${f_red}${status}${f_reset}"
    else
        prompt="${prompt}${sep}${f_gray}${status}${f_reset}"
    fi

    # Current directory
    prompt="${prompt}${sep}${f_gray}\w${f_reset}"

    # Suffix
    prompt="${prompt}${sep}\$${f_reset}"

    # Window title
    prompt="\[\033]2;\u@\h\007\]${prompt}"

    # Tab title
    prompt="\[\033]1;\w\007\]${prompt}"

    # Set the prompt
    PS1="${prefix_color}${prefix}${f_reset}${prompt} "

    # Append the last command to the history file
    history -a
}

export PROMPT_DIRTRIM=2
export PROMPT_COMMAND=_my_prompt
