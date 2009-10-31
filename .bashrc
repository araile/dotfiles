[ -z "$PS1" ] && return  # return if not running interactively
source /etc/profile >/dev/null

# misc settings
set -o emacs  # input style
shopt -s checkwinsize  # check and update lines & cols after each cmd
shopt -s cmdhist   # multiline commands saved in history as oneliners
export EDITOR=vim
export IGNOREEOF=1  # ignore accidental Ctrl-D's

# locale
export LC_ALL="en_IE.UTF-8"
export LC_CTYPE=$LC_ALL LC_TIME=$LC_ALL LANG=$LC_ALL

# history
export HISTCONTROL='ignoreboth:erasedups'
export HISTFILE='/dev/null'

# python
export PYTHONPATH="$HOME/lib/python"
export PYTHONSTARTUP="$HOME/.pythonrc.py"

# pager
export PAGER=less
export LESSCHARSET=utf-8
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;37m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# variables
uname=$(uname)

# terminal title
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}\007"'
    ;;
*)
    ;;
esac

#----------------------------------------------------------------------
# prompt
#----------------------------------------------------------------------
c0="\[\033[0m\]"        # reset
c1="\[\033[1;30m\]"     # dark grey
c2="\[\033[0;40m\]"     # white on black

function parse_git_branch()
{
    # get the branch -- http://gist.github.com/5129
    b="$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    [ -n "$b" ] && echo " [$b]";
}

function bash_prompt()
{
    info="${c1}\u@\h ${c2}\w${c1}\$(parse_git_branch)${c0}\n"
    echo "${info}${c1}${lvl}\$ ${c0}"
}

PS1="`bash_prompt`"
PS2="$c1. $c0"
#----------------------------------------------------------------------

# ls colours
if [ "$TERM" != "dumb" ]; then
    case "$uname" in
    Darwin|FreeBSD)
        export CLICOLOR=1
        export LSCOLORS="ExFxCxDxBxegedabagacad"  # legible colours
        ;;
    *)
        if [ -n "`which dircolors`" ]; then
            eval "`dircolors -b`" 2>/dev/null
            alias ls='ls --color=auto' 2>/dev/null
        fi
        ;;
    esac
fi

# shortcuts
alias d='dict'
alias l='ls -Fhl'
alias la='ls -AF'
alias lc='ls -F'
alias ll='ls -AFhl'
alias m='mutt -y'
alias s='screen -DRA && stty sane && echo'
alias v='vim'

# help me
alias :e='vim'
alias :q='logout'

# `.. 3` will `cd ..` 3 times
function .. () {
    local arg=${1:-1}; while [ $arg -gt 0 ]; do
        cd .. >&/dev/null; arg=$(($arg - 1))
    done
}

# create directories and cd to the first one
function mkcd() { [ -n "$1" ] && mkdir -p "$@" && cd "$1"; }

# calculator
function calc() { [ -z "$@" ] && bc -ql || echo "$@" | bc -l; }

# git
alias gb='git branch' gba='git branch -a'
alias gc='git commit -v' gca='git commit -a'
alias gd='git diff'
alias gl='git pull'
alias glog='git log --stat'
alias gp='git push'
alias gst='git status'

#----------------------------------------------------------------------
# rsync shortcut for backing up / mirroring files.
#
# 'cpr src/ dest/' will copy files from src to dest. Note the trailing
# slash after src -- if this is omitted, the command will look for or
# create a folder in dest named after src, and copy to that instead.
#
# Replace 'cpr' with 'scpr' when transferring between servers.
# To run with low priority, prepend 'n' to the command.
#----------------------------------------------------------------------
cpr="rsync -Phavz --modify-window=1 \
        --exclude '.DS_Store' --exclude 'Thumbs.db' --exclude '*.swp' \
        --exclude '.Trashes' --exclude '.fseventsd'"
scpr="$cpr -e 'ssh -4 -xac blowfish-cbc'"

rsync_v="`rsync --version 2>/dev/null`"
[ -n "`echo $rsync_v | grep xattrs`" ] && cpr="$cpr --xattrs"

alias cpr="$cpr" ncpr="nice -n19 $cpr"
alias scpr="$scpr" nscpr="nice -n19 $scpr"

unset cpr scpr rsync_v
#----------------------------------------------------------------------

# colour diff for scm/vcs
# requires: colordiff
function dif {
    for scm in git hg; do
        if [ -d ".$scm" ]; then
            $scm diff $1 | colordiff | less -R
            return 0
        fi
    done
    echo 'cannot find SCM type'
    return 1
}

# zfs
alias zlist='zfs list -t filesystem'
alias zim='zpool import' zex='zpool export'
function zshot() {
    if [ -n "$1" ]; then
        zfs snapshot "$1@`date +%Y-%m-%d-%H%M`"
    else
        zfs list -t snapshot
    fi
}

case $uname in
SunOS)
    ;;
*)
    # bash completion
    for f in /usr/local/etc/bash_completion "$HOME/.bash/bash_completion"
    do
        if [ -e "$f" ]; then
            export BASH_COMPLETION="$f"
            source "$f"
            break
        fi
    done

    # more scripts in ~/.bash/
    source "$HOME/.bash/gitcomplete"
    ;;
esac

# store machine-specific settings in ~/.bashrc.local
[ -e "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
