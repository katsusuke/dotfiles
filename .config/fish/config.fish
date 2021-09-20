export GOPATH=$HOME/.go
alias g=git

source ~/.asdf/asdf.fish

function peco_select_history
  if test (count $argv) = 0
    set peco_flags
  else
    set peco_flags --query "$argv"
  end

  history|peco $peco_flags|read foo

  if [ $foo ]
    commandline $foo
  else
    commandline ''
  end
end

function peco_ghq_list
  if test (count $argv) = 0
    set peco_flags
  else
    set peco_flags --query "$argv"
  end

  ghq list|peco $peco_flags|read foo

  if [ $foo ]
    set root (ghq root)
    commandline 'cd '$root/$foo
  else
    commandline ''
  end
end

function fish_user_key_bindings
    bind \cr peco_select_history
    bind \cl peco_ghq_list
end
