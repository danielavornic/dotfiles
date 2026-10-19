export PATH="$HOME/.local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting vi-mode)
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH=$PATH:/usr/local/bin
export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:/home/danielavornic/bin"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

alias y='yazi'

# bun completions
[ -s "/home/danielavornic/.bun/_bun" ] && source "/home/danielavornic/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias tt='timetrace'

eval "$(zoxide init zsh)"
alias cd='z'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH=$PATH:~/go/bin
export PATH=$PATH:/usr/local/go/bin

alias oo="cd ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/DanaGardens"


alias ls='eza -l --icons --group-directories-first --color=always'

[[ $(uname) == "Linux" ]] && alias fd="fdfind" && alias cat="batcat"
[[ $(uname) == "Darwin" ]] && alias cat="bat"

alias szsh="source ~/dotfiles/zshrc/.zshrc"
alias oc="opencode"

# for my linux setup
alias telegram='~/Downloads/Telegram/Telegram'



# pnpm
export PNPM_HOME="/Users/danielavornic/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


pish() {
  local type=$1
  local source=$2

  local types="Types: m (music), ab (audiobook), mv (movie), tv (show)"

  if [[ -z "$type" ]] || [[ -z "$source" ]]; then
    echo "Usage: pish <type> <source>"
    echo "$types"
    return 1
  fi

  local rp_host="rp@100.107.195.89"
  local rp_base="/srv/media"
  local dest

  case $type in
    m|music)        dest=music ;;
    ab|audiobook)   dest=audiobooks ;;
    mv|movie)       dest=movies ;;
    tv|show)        dest=shows ;;
    *)
      echo "Unknown type: $type"
      echo "$types"
      return 1
      ;;
  esac

  rsync -rtv "$source" "$rp_host:$rp_base/$dest/"
}

 export VISUAL=/opt/homebrew/bin/nvim
   export EDITOR=/opt/homebrew/bin/nvim
