autoload -U zmv

if [[ -d ~/.zsh/completion ]]; then
    fpath=(~/.zsh/completion $fpath)
fi

autoload colors
colors

# LS_COLORSを設定しておく
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # ファイル補完候補に色を付ける
zstyle ':completion:*:default' menu select=2 # 補完侯補をメニューから選択する。select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。

# option + 矢印でワード移動
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

setopt auto_pushd # cd したら pushd
stty stop undef # C-s での画面停止を無効

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

# alias
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

if [ -f ~/.private.zsh ]; then
    source ~/.private.zsh
fi

# envs
if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

export HOMEBREW_NO_AUTO_UPDATE=1

export PAGER='less -X'
export EDITOR=E

# User configuration
export PATH=$HOME/.local/bin:$HOME/.emacs.d/bin:$HOME/bin:$HOME/.dotnet/tools:$HOME/git/github.com/katsusuke/private-tools:$PATH
if [[ -d $HOME/git/github.com/OmniSharp/omnisharp-roslyn/bin/Release/OmniSharp.Stdio.Driver/net6.0 ]]; then
  export PATH=$PATH:$HOME/git/github.com/OmniSharp/omnisharp-roslyn/bin/Release/OmniSharp.Stdio.Driver/net6.0
fi

# svn
export SVN_EDITOR=emacs
# golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
# claude
export DISABLE_MICROCOMPACT=1
# Azure size
export AZURE_SIZE=Standard_A0

# eval "$(~/.local/bin/mise activate zsh)"
# sims モードじゃないと claude code が認識しない
eval "$(~/.local/bin/mise activate zsh --shims)" 

# pipenv
#eval "$(pipenv --completion)"
# direnv
eval "$(direnv hook zsh)"

export STUDIO_JDK=${JAVA_HOME%/*/*}
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# rust
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# Erlang
export ERL_AFLAGS="-kernel shell_history enabled"


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

function fzf-select-path() {
  local src=$(ghq list | fzf --preview "ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print \$9\"/\"\$6\"/\"\$7 \" \" \$10}'")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}

zle -N fzf-select-path
bindkey '^gl' fzf-select-path

autoload -Uz compinit && compinit

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

eval "$(starship init zsh)"

export FZF_DEFAULT_OPTS='--layout=reverse --border --height 100%'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. "$HOME/.local/bin/env"

# Added by Antigravity
export PATH="/Users/katsusuke/.antigravity/antigravity/bin:$PATH"
