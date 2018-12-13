#!/bin/zsh
#历史纪录
TERM=xterm
export HISTSIZE=10000
export HISTFILE="$HOME/.zhistory"
export SAVEHIST=$HISTSIZE
# append history record
setopt INC_APPEND_HISTORY
# remove duplicate command ($fc -l will get unique command list)
setopt HIST_IGNORE_DUPS
# add timestaps
setopt EXTENDED_HISTORY
##
setopt HIST_IGNORE_SPACE
# auto pushd after cd , press $cd -<tab> show dir stack
setopt AUTO_PUSHD
# remove duplicate path
setopt PUSHD_IGNORE_DUPS

# word pattern
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

# 命令提示符
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]];then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BLACK GREY DEFAULT;do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

PROMPT="[$PR_BLUE%n$PR_NO_COLOR@$PR_GREEN%U%m%u$PR_NO_COLOR:$PR_RED%1~$PR_NO_COLOR]%(!.#.$) "
RPROMPT="$PR_LIGHT_YELLOW%T $PR_CYAN%/$PR_NO_COLOR"

# vcs_info
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT='$PR_LIGHT_YELLOW%T $PR_CYAN%/$PR_NO_COLOR $(vcs_info_wrapper)'

# 开启系统补全
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE
autoload -U compinit
compinit

#补全类型提示分组 
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format "$PR_LIGHT_CYAN--- %d ---$PR_NO_COLOR"
zstyle ':completion:*:messages' format "$PR_YELLOW--- %d ---$PR_NO_COLOR"
zstyle ':completion:*:warnings' format "$PR_LIGHT_RED--- No Matches Found ---$PR_NO_COLOR"

#路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-shlashes 'yes'
zstyle ':completion::complete:*' '\\'

zstyle ':completion:*' menu select
zstyle ':completion:*:*:default' force-list always

#错误校正      
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

#kill 命令补全      
compdef pkill=kill
compdef pkill=killall
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

#自动补全选项
zstyle ':completion:*:match:*' original only
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

#彩色补全菜单
eval $(dircolors -b)
export ZLSCOLORS="${LS_COLORS}"
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31' 
#自动补全缓存
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zcache
#zstyle ':completion:*:cd:*' ignore-parents parent pwd

#别名设置
alias emacs='emacs -nw'
alias ls='ls --color=auto'
alias tmux='tmux -2'

#Python补全
export PYTHONSTARTUP="/home/yue/.config/pythonstartup.py"
alias goodbye='shutdown -h now'
