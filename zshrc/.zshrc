export PATH="$HOME/.local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting vi-mode npm-aliases)
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=$PATH:/home/danielavornic/.spicetify
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/usr/local/bin
export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:/home/danielavornic/bin"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

alias y='yazi'

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "/home/danielavornic/.bun/_bun" ] && source "/home/danielavornic/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH=/home/danielavornic/.opencode/bin:$PATH

alias tt='timetrace'

eval "$(zoxide init zsh)"
alias cd='z'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias oo="cd ~/DanaGardens"

if [[ -z "$NVIM" ]] && command -v theme.sh > /dev/null; then
	[ -e ~/.theme_history ] && theme.sh "$(theme.sh -l|tail -n1)"

	# Optional

	# Bind C-o to the last theme.
	last_theme() {
		theme.sh "$(theme.sh -l|tail -n2|head -n1)"
	}

	zle -N last_theme
	bindkey '^O' last_theme

	alias th='theme.sh -i'

	# Interactively load a light theme
	alias thl='theme.sh --light -i'

	# Interactively load a dark theme
	alias thd='theme.sh --dark -i'
fi

alias ls='eza -l --icons --group-directories-first --color=always'

wtf() {
  local port="${1:-3000}"
  lsof -i "tcp:$port"
}

alias killport='f() { sudo kill -9 $(lsof -t -i :"$1"); }; f'

alias fd="fdfind"
alias cat="batcat"

alias szsh="source ~/dotfiles/zshrc/.zshrc"
alias telegram='~/Downloads/Telegram/Telegram'

alias oc="opencode"

export PATH=$PATH:~/go/bin
export PATH=$PATH:/usr/local/go/bin

