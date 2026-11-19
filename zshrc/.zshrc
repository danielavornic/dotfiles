# .NET SDK and global tools (Power Platform CLI)
if [[ -d "$HOME/.dotnet" ]]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi

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
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
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
  ~/.bun/bin/bun ~/Projects/pish/src/cli.ts "$@"
}

 export VISUAL=/opt/homebrew/bin/nvim
   export EDITOR=/opt/homebrew/bin/nvim

# Dev containers for the current folder: dc-up, dc-run claude, dc-sh, dc-down, ...
source "$HOME/dotfiles/zshrc/devcontainer.zsh"

# Railpen harness: the dc-* functions pinned to harness-agent, from any folder
export RAILPEN_HA="$HOME/railpen_dev1/harness-agent"
alias rp-up='DC_WORKSPACE=$RAILPEN_HA dc-up'
alias rp-claude='DC_WORKSPACE=$RAILPEN_HA dc-exec claude'
alias rp-sh='DC_WORKSPACE=$RAILPEN_HA dc-sh'
alias rp-rebuild='DC_WORKSPACE=$RAILPEN_HA dc-rebuild'
alias rp-down='DC_WORKSPACE=$RAILPEN_HA dc-down'
alias rp-forward='DC_WORKSPACE=$RAILPEN_HA dc-forward'
# Credential proxy (rp-up starts it; reload after editing ~/.config/railpen/cred-proxy.env)
alias rp-proxy-reload='docker compose -f "$RAILPEN_HA/proxy/compose.yaml" up --detach --force-recreate --wait'
alias rp-proxy-status='docker ps --filter name=railpen-cred-proxy --format "{{.Names}} {{.Status}}"'
alias rp-proxy-logs='docker logs --tail 50 -f railpen-cred-proxy'
export RAILPEN_KB_PATH="/mnt/c/Users/DanVor/OneDrive - Softwire Technology Limited/Consulting - Low Code Citizen Developer Accelerator Programme"
[[ -r ~/.config/railpen/secrets.env ]] && source ~/.config/railpen/secrets.env   # RAILPEN_GITLAB_TOKEN
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Added by the Hunk installer (https://hunk.dev)
export PATH='/home/danvor/.hunk/bin':"$PATH"
# herdr-automatic-rename: live tab naming hook
for _f in $HOME/.config/herdr/plugins/github-installations/herdr-automatic-rename-*/*/checkout/shell/hook.zsh(N) \
          $HOME/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f; break
done
