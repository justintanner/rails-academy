# History control
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTSIZE=32768
export HISTFILESIZE="${HISTSIZE}"

# Make sure Homebrew is in the PATH
export PATH="$PATH:/usr/local/bin:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin"

# Nicer reverse search with fzf
type fzf &>/dev/null && eval "$(fzf --bash)"

# Bash auto-completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# Setup Mise to manages rubies, node versions, python, env variables, and more.
eval "$(~/.local/bin/mise activate bash)"

# Default prompt get overridden below.
export PS1='$ '

# Bash bash-git-prompt, this will override the PS1 set above.
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_THEME=Solarized_Ubuntu
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

# Terraform bash completion
if command -v terraform >/dev/null 2>&1; then
   complete -C /opt/homebrew/bin/terraform terraform
fi

# Default editor (possible values: emacs, vim, nvim, and more)
export EDITOR=nano
export SUDO_EDITOR=${EDITOR}

# Suppress the zsh warning message.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Tell Mise to automatically load the .env when you enter that directory.
export MISE_ENV_FILE=.env

# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Tools
alias n='nvim'
alias e='emacs'
alias g='git'
alias d='docker'
alias r='rails'
alias lzg='lazygit'
alias lzd='lazydocker'

# Git shortcuts
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gcbr='git checkout -b'
alias gpfo='git push --force'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"
