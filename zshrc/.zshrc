export PATH="$HOME/.local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting vi-mode)
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH=$PATH:~/.local/bin
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

# if [[ -z "$NVIM" ]] && command -v theme.sh > /dev/null; then
# 	[ -e ~/.theme_history ] && theme.sh "$(theme.sh -l|tail -n1)"

# 	# Optional

# 	# Bind C-o to the last theme.
# 	last_theme() {
# 		theme.sh "$(theme.sh -l|tail -n2|head -n1)"
# 	}

# 	zle -N last_theme
# 	bindkey '^O' last_theme

# 	alias th='theme.sh -i'

# 	# Interactively load a light theme
# 	alias thl='theme.sh --light -i'

# 	# Interactively load a dark theme
# 	alias thd='theme.sh --dark -i'
# fi

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

conda config --set auto_activate false

pish() {
  local type=$1
  local source=$2

  if [[ -z "$type" ]] || [[ -z "$source" ]]; then
    echo "Usage: pish <type> <source>"
    echo "Types: ab (audiobook), m (music)"
    return 1
  fi

  local rp_host="rp@rp.local"
  local rp_base="/media/rp/E269-F024/media"
  local rp_jellyfin="/media/rp/E269-F024/jellyfin/media"

  case $type in
    ab|audiobook)
      rsync -av "$source" "$rp_host:$rp_base/audiobookshelf/audiobooks/"
      ;;
    m|music)
      rsync -av "$source" "$rp_host:$rp_base/music/"
      ;;
    *)
      echo "Unknown type: $type"
      echo "Types: ab (audiobook), m (music)"
      return 1
      ;;
  esac
}

