autoload -U zmv

autoload -U compinit
compinit

# LS_COLORSを設定しておく
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


# ファイル名
export HISTFILE=${HOME}/.zsh_history
# ヒストリに保存するコマンド
export HISTSIZE=100000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=10000000
# 重複を記録しない
setopt hist_ignore_dups
# 以下のコマンドは記録しない(?や* も使える)
export HISTIGNORE=pwd:ls:la:ll:lla:exit
# C-s での画面停止を無効
stty stop undef

# alias
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
# keys
if [ -f ~/.private.zsh ]; then
    source ~/.private.zsh
fi

# envs
export PAGER='less -X'
export EDITOR=E

# User configuration
export PATH=$HOME/bin:$HOME/git/github.com/katsusuke/private-tools:/usr/local/sbin:/usr/local/bin:$PATH

# symlink diff-highlight
#if [ ! -e $HOME/bin/diff-highlight ]; then
#    ln -s /usr/local/bin/$(dirname $(readlink /usr/local/bin/git))/../share/git-core/contrib/diff-highlight/diff-highlight $HOME/bin/diff-highlight
#fi

export BREWOPT=/usr/local/opt
# svn
export SVN_EDITOR=emacs
export MAGICK_HOME="/opt/local/bin"
# golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin
# Azure size
export AZURE_SIZE=Standard_A0
if [[ -d $HOME/.pyenv ]];then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
# rbenv
eval "$(rbenv init -)"
# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
export PATH="node_modules/.bin:$PATH"

# Java
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export STUDIO_JDK=${JAVA_HOME%/*/*}
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# rust
export PATH=$HOME/.cargo/bin:$PATH

# MacTex
export PATH=$PATH:/usr/local/texlive/2017basic/bin/x86_64-darwin

# BREW
export BREW_PREFIX=/usr/local
export PATH="/usr/local/opt/postgresql@10/bin:$PATH"

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function peco-select-path() {
  local filepath="$(find . | grep -v '/\.' | peco --prompt 'PATH>')"
  if [ "$LBUFFER" -eq "" ]; then
    if [ -d "$filepath" ]; then
      BUFFER="cd $filepath"
    elif [ -f "$filepath" ]; then
      BUFFER="$EDITOR $filepath"
    fi
  else
    BUFFER="$LBUFFER$filepath"
  fi
  CURSOR=$#BUFFER
  zle clear-screen
}

zle -N peco-select-path
bindkey '^f' peco-select-path # Ctrl+f で起動

function peco-select-gitadd() {
    local SELECTED_FILE_TO_ADD="$(git status --porcelain | \
                                  peco --query "$LBUFFER" | \
                                  awk -F ' ' '{print $NF}')"
    if [ -n "$SELECTED_FILE_TO_ADD" ]; then
      BUFFER="git add $(echo "$SELECTED_FILE_TO_ADD" | tr '\n' ' ')"
      CURSOR=$#BUFFER
    fi
    zle accept-line
    # zle clear-screen
}
zle -N peco-select-gitadd
bindkey "^ga" peco-select-gitadd

function peco-checkout-branch() {
    local BRANCH="$(git --no-pager branch -a|ruby -e 'bs=readlines.map(&:strip);lb=bs.select{|b|!(/^remotes\/origin/ =~ b)};rb=bs.select{|b|/^remotes\/origin/ =~ b}.select{|b|!b.include?("->") && !lb.include?(b.gsub("remotes/origin/",""))};puts lb.select{|b|!(/^\*/ =~ b)} + rb'|peco --prompt 'git checkout')"
    if [ -n "$BRANCH" ]; then
	BUFFER="git checkout '$(echo $BRANCH | sed 's/remotes\/origin\///g')'"
    fi
    zle clear-screen
}
zle -N peco-checkout-branch
bindkey '^gb' peco-checkout-branch

function peco-cd-ghq() {
    local cdto="$(ghq list -p | peco --prompt 'cd ')"
    echo "LBUFFER:$LBUFFER"
    if [ -n "$cdto" ]; then
	BUFFER="cd $cdto"
    fi
    zle clear-screen
}
zle -N peco-cd-ghq
bindkey '^gl' peco-cd-ghq

function rvm-gemset-cd() {
    local gemset=$(rvm list gemsets|rvm_gemset_list|peco --prompt 'gemset>'|awk '{print $1}')
    if [ "$LBUFFER" -eq "" ]; then
	local gem=$(echo "$(ls --color=none ~/.rvm/gems/$gemset/gems) $(ls --color=none ~/.rvm/gems/$gemset/bundler/gems)"|peco)
	if [ "$LBUFFER" -eq "" ]; then
	    if [ -d "$HOME/.rvm/gems/$gemset/gems/$gem" ]; then
		BUFFER="cd ~/.rvm/gems/$gemset/gems/$gem"
	    else
		BUFFER="cd ~/.rvm/gems/$gemset/bundler/gems/$gem"
	    fi
	fi
    fi
    zle clear-screen
}
zle -N rvm-gemset-cd
bindkey '^gs' rvm-gemset-cd

function peco-kill() {
    local process="$(ps aux |tail -n +2| peco --prompt 'kill '|awk '{print $2}')"
    if [ -n "$process" ]; then
	BUFFER="kill $process"
    fi
    zle clear-screen
}
zle -N peco-kill
bindkey '^gk' peco-kill

eval "$(starship init zsh)"
