#!/bin/bash

if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
  GREEN_CHECK="\e[32m✅\e[0m"
  RED_X="\e[31m❌\e[0m"
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

  # Print additional message if provided
  if [[ -n "$additional_message" ]]; then
    echo -e "   $additional_message"
  fi

  # Exit only if exit_code is 1
  if [[ "$exit_code" -eq 1 ]]; then
    exit 1
  fi
}

if xcode-select -p >/dev/null 2>&1; then
  good "Xcode Command Line Tools are installed."
else
  bad "Xcode Command Line Tools are NOT installed. Instructions: " "https://github.com/justintanner/rails-academy/blob/main/mac/README.md" 1
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
packages=(fzf ripgrep bat eza zoxide btop httpd fd tldr ruby-build bash-completion bash-git-prompt imagemagick vips libpq mysql-client 1password-cli)

for package in "${packages[@]}"; do
  if brew list -1 | grep -q "^${package}\$"; then
    good "${package} is already installed."
  else
    echo "Installing ${package}..."
    brew install "${package}"
  fi
done

if command -v terraform >/dev/null 2>&1; then
  good "Terraform already installed."
else
  echo "Installing Terraform..."
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
fi

echo "Installing cask libraries..."
casks=(font-hack-nerd-font font-jetbrains-mono-nerd-font chromedriver)

for cask in "${casks[@]}"; do
  if brew list --cask -1 | grep -q "^${cask}\$"; then
    good "Homebrew cask ${cask} is already installed."
  else
    echo "Installing ${cask}..."
    brew install --cask "${cask}"
  fi
done

# "apps" and "app_names must" be in the same order.
apps=(
  docker
  flameshot
  alacritty
  1password
  visual-studio-code
  rubymine
  localsend
  google-chrome
)

app_names=(
  Docker
  Flameshot
  Alacritty
  1Password
  "Visual Studio Code"
  RubyMine
  LoadSend
  Google Chrome
)

for i in "${!apps[@]}"; do
  app="${apps[$i]}"
  app_name="${app_names[$i]}"
  if [ ! -f "/Applications/${app_name}.app" ]; then
    good "App ${app_name} is installed."
  else
    echo "App ${app_name} is not installed. Installing..."
    brew install --cask "${app}"
    xattr -dr com.apple.quarantine "/Applications/${app_name}.app"
  fi
done

if command -v mise >/dev/null 2>&1; then
  good "Mise is installed."
else
  echo "Installing Mise..."
  curl https://mise.run | sh
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
}

install_only_if_missing() {
  local source=$1
  local dest=$2

  if [ ! -f $dest ]; then
    cp $source $dest
  fi
}

echo "Installing config files..."
install_and_backup_old_file ~/.local/share/rails-academy/config/.alacritty.toml ~/.alacritty.toml
install_only_if_missing ~/.local/share/rails-academy/mac/.bash_aliases ~/.bash_aliases
install_only_if_missing ~/.local/share/rails-academy/mac/.bash_env ~/.bash_env
install_only_if_missing ~/.local/share/rails-academy/mac/.bash_op ~/.bash_op
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bash_profile ~/.bash_profile
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bashrc ~/.bashrc
install_and_backup_old_file ~/.local/share/rails-academy/mac/.zshrc ~/.zshrc

echo "Setting bash as the default terminal..."
chsh -s /bin/bash
defaults write com.apple.Terminal Shell -string "/bin/bash"

echo "Setting fonts in Terminal..."
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "JetBrainsMonoNF-Regular"'
osascript -e 'tell application "Terminal" to set font size of settings set "Basic" to 14'

echo "Install the latest node as the default..."
mise use --global node@lts

echo "Installing ruby 3.3 as the default..."
mise use --global ruby@3.3

echo "Installing rails8..."
mise x ruby -- gem install rails --no-document -v ">= 8.0.0beta1"

good "\nSuccessfully installed Rails Academy\n"
echo "Please restart your terminal to apply the changes."
