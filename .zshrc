autoload -U zmv

fpath=(~/.zsh/completion $fpath)
autoload -U compinit
compinit
autoload colors
colors

# LS_COLORSを設定しておく
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # ファイル補完候補に色を付ける
zstyle ':completion:*:default' menu select=2 # 補完侯補をメニューから選択する。select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。

setopt auto_pushd # cd したら pushd

# history
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
setopt share_history  # シェルのプロセスごとに履歴を共有
setopt inc_append_history # 複数の zsh を同時に使う時など history ファイルに上書きせず追加


# C-s での画面停止を無効
stty stop undef

# alias
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# envs
export PAGER='less -X'
export EDITOR=E

# User configuration
export PATH=$HOME/local/bin:$HOME/git/github.com/katsusuke/private-tools:/usr/local/sbin:/usr/local/bin:$PATH

# ptosh mongodb
export PATH=$PATH:/usr/local/Cellar/mongodb-community@3.6/3.6.18/bin

export BREWOPT=/usr/local/opt
# svn
export SVN_EDITOR=emacs
export MAGICK_HOME="/opt/local/bin"
# golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin
# Azure size
export AZURE_SIZE=Standard_A0

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
export PATH="node_modules/.bin:$PATH"
# pipenv
eval "$(pipenv --completion)"

# Java
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

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

# cask
export PATH="$HOME/.cask/bin:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

function update-diff-highlight() {
    src=/usr/local/bin/$(dirname $(readlink /usr/local/bin/git))/../share/git-core/contrib/diff-highlight/diff-highlight
    dist=$HOME/bin/diff-highlight
    # symlink diff-highlight
    rm -f $dist
    ln -s ${src:a} $dist
}

function peco-select-history() {
    fc -R
    BUFFER=$(fc -lrn 1 | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
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

function peco-switch-branch() {
    local BRANCH="$(git --no-pager branch -a|ruby -e 'bs=readlines.map(&:strip);lb=bs.select{|b|!(/^remotes\/origin/ =~ b)};rb=bs.select{|b|/^remotes\/origin/ =~ b}.select{|b|!b.include?("->") && !lb.include?(b.gsub("remotes/origin/",""))};puts lb.select{|b|!(/^\*/ =~ b)} + rb'|peco --prompt 'git switch' --selection-prefix '👉')"
    if [ -n "$BRANCH" ]; then
	BUFFER="git switch '$(echo $BRANCH | sed 's/remotes\/origin\///g')'"
    fi
    zle clear-screen
}
zle -N peco-switch-branch
bindkey '^gb' peco-switch-branch

function peco-cd-ghq() {
    local cdto="$(ghq list -p | peco --prompt 'cd ' --selection-prefix '👉')"
    echo "LBUFFER:$LBUFFER"
    if [ -n "$cdto" ]; then
	BUFFER="cd $cdto"
    fi
    zle clear-screen
}
zle -N peco-cd-ghq
bindkey '^gl' peco-cd-ghq

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
