alias g=git

set -x PATH $HOME/.fzf/bin $HOME/go/bin /usr/local/go/bin $PATH


function peco_ghq_list
  if test (count $argv) = 0
    set peco_flags
  else
    set peco_flags --query "$argv"
  end

  ghq list|fzf $peco_flags|read foo

  if [ $foo ]
    set root (ghq root)
    commandline 'cd '$root/$foo
  else
    commandline ''
  end
end

function fish_user_key_bindings
    bind \cl peco_ghq_list
end

