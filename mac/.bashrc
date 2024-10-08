# ENV Vars
[[ -f ~/.bash_env ]] && . ~/.bash_env

# Nicer reverse search with fzf
type fzf &>/dev/null && eval "$(fzf --bash)"

# Bash auto-completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# Setup Mise to manages rubies, node versions, python, env variables, and more.
eval "$(~/.local/bin/mise activate bash)"

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

# Load aliases like gcbr, gcam, etc.
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases


