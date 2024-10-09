#!/bin/bash

echo -e "Installing Rails Academy...\n"

if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
  GREEN_CHECK="✅"
  RED_X="❌"
else
  GREEN_CHECK="✓"
  RED_X="✗"
fi

good() {
  echo -e "${GREEN_CHECK} $1"
}

bad() {
  local message="$1"
  local additional_message="$2"
  local exit_code="${3:-0}"

  echo -e "\n${RED_X} ${message}"

  if [[ -n "$additional_message" ]]; then
    echo -e $additional_message
  fi

  if [[ "$exit_code" -eq 1 ]]; then
    exit 1
  fi
}

if xcode-select -p >/dev/null 2>&1; then
  good "Xcode Command Line Tools are installed."
else
  INSTRUCTIONS_URL="https://github.com/justintanner/rails-academy/blob/main/mac/README.md"
  bad "Xcode Command Line Tools are NOT installed. Instructions: " $INSTRUCTIONS_URL 1
fi

if ! command -v brew >/dev/null 2>&1; then
  # Homebrew might not be in path yet, inject it.
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  bad "Error: Homebrew is not installed. Instructions: " "https://brew.sh" 1
else
  good "Homebrew is installed."
  export PATH="$PATH:/usr/local/bin:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin"
fi

if command -v git >/dev/null 2>&1; then
  good "Git is installed."
else
  echo "Git not installed. Installing..."
  brew install git
fi

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  cd ~/.local/share/rails-academy
  git fetch origin "${RAILS_ACADEMY_REF:-stable}" && git checkout "${RAILS_ACADEMY_REF:-stable}"
  cd -
fi

echo "Setting git defaults..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global push.autoSetupRemote true

echo "Installing command line utils..."
packages=(fzf ripgrep bash bat eza zoxide btop httpd fd tldr ruby-build bash-completion bash-git-prompt imagemagick vips libpq mysql-client 1password-cli)

for package in "${packages[@]}"; do
  if brew list -1 | grep -q "^${package}\$"; then
    good "Homebrew package ${package} is installed."
  else
    echo "Installing ${package}..."
    brew install "${package}"
  fi
done

if command -v terraform >/dev/null 2>&1; then
  good "Terraform is installed."
else
  echo "Installing Terraform..."
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
fi

echo -e "\nInstalling cask libraries..."
casks=(font-hack-nerd-font font-jetbrains-mono-nerd-font chromedriver)

for cask in "${casks[@]}"; do
  if brew list --cask -1 | grep -q "^${cask}\$"; then
    good "Homebrew cask ${cask} is installed."
  else
    echo "Installing ${cask}..."
    brew install --cask "${cask}"
  fi
done

# Format: "cask:App Name" (App Name matches the name in /Applications)
apps=(
  "docker:Docker"
  "alacritty:Alacritty"
  "1password:1Password"
  "rubymine:RubyMine"
  "google-chrome:Google Chrome"
)

for app_pair in "${apps[@]}"; do
  app="${app_pair%%:*}"
  app_name="${app_pair##*:}"
  if [ -e "/Applications/${app_name}.app" ]; then
    good "${app_name} is installed."
  else
    echo "${app_name} is not installed. Installing..."
    brew install --cask "${app}"
    xattr -dr com.apple.quarantine "/Applications/${app_name}.app"
  fi
done

# Just in case Mise needs these in the path to build ruby
if [ -d "/opt/homebrew/opt/mysql-client" ]; then
  export PATH="$PATH:/opt/homebrew/opt/mysql-client/bin"
  export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/mysql-client/lib"
  export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/mysql-client/include"
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/opt/mysql-client/lib/pkgconfig"
fi

if [ -d "/opt/homebrew/opt/libpq" ]; then
  export PATH="$PATH:/opt/homebrew/opt/libpq/bin"
  export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/libpq/lib"
  export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/libpq/include"
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/opt/libpq/lib/pkgconfig"
fi

if command -v mise >/dev/null 2>&1; then
  good "Mise is installed."
else
  echo "Installing Mise..."
  curl https://mise.run | sh
  PATH=$PATH:$HOME/.local/bin
  mise activate
fi

if [ -f /usr/local/bin/rubymine ]; then
  good "Rubymine shell script installed."
else
  echo "Installing \"rubymine\" shell script..."
  sudo cp ~/.local/share/rails-academy/mac/rubymine /usr/local/bin/rubymine
  sudo chmod +x /usr/local/bin/rubymine
fi

backup_file() {
  local file=$1
  local backup=$file.bak
  local count=1

  while [ -f $backup ]; do
    backup=$file.bak$count
    count=$((count + 1))
  done

  mv $file $backup
}

install_and_backup_old_file() {
  local source=$1
  local dest=$2

  if [ -f $dest ] && ! cmp -s $dest $source; then
    backup_file $dest
    echo "Backed up old config file to $dest.bak"
  fi

  cp $source $dest
  good "Installed config $dest."
}

install_only_if_missing() {
  local source=$1
  local dest=$2

  if [ ! -f $dest ]; then
    cp $source $dest
    good "Installed config $dest."
  else
    good "Skipped installing config $dest"
  fi
}

echo -e "\nInstalling config files..."
install_and_backup_old_file ~/.local/share/rails-academy/mac/.alacritty.toml ~/.alacritty.toml
install_only_if_missing ~/.local/share/rails-academy/mac/.op_load_env ~/.op_load_env
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bash_profile ~/.bash_profile
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bashrc ~/.bashrc
install_and_backup_old_file ~/.local/share/rails-academy/mac/.zshrc ~/.zshrc
install_and_backup_old_file ~/.local/share/rails-academy/mac/bash/inputrc ~/.inputrc

echo -e "\nSetting bash as the default terminal..."
chsh -s /opt/homebrew/bin/bash
defaults write com.apple.Terminal Shell -string "/opt/homebrew/bin/bash"

echo "Setting fonts in Terminal..."
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "JetBrainsMonoNF-Regular"'
osascript -e 'tell application "Terminal" to set font size of settings set "Basic" to 14'

echo "Installing ruby 3.3 as the default..."
mise use --global ruby@3.3

echo "Installing rails8..."
mise x ruby -- gem install rails --no-document -v ">= 8.0.0beta1"

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
