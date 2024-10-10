#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMAKUB_SUB_PATH="$SCRIPT_PATH/vendor/omakub"

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

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone --recurse-submodules https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
  git submodule update --init --recursive
fi
cd -

echo "Setting git defaults..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

echo "Installing command line utils..."
sudo apt install -y fzf ripgrep bat eza zoxide plocate btop apache2-utils fd-find tldr

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

echo "Installing ruby 3.3 as the default..."
mise use --global ruby@3.3

echo "Installing rails8..."
mise x ruby -- gem install rails --no-document -v ">= 8.0.0beta1"

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
