#!/usr/bin/env bash

# Check if running interactively
if [[ ! -t 0 ]]; then
  exec bash -i "$0" "$@"
fi

echo -e "Installing Rails Academy on a Mac...\n"

echo    "Select installation mode:"
echo    "  - Press Enter to install everything"
echo -e "  - Type 'c' for custom install (for computer programmers)\n"
read -rp "Enter option [Enter/c]: " install_mode

install_everything() {
  [[ -z "$install_mode" ]]
}

prompt_install() {
  local description="$1"
  read -rp "Install ${description}? [Y/n]: " choice
  [[ "$choice" =~ ^[Yy]$ || "$choice" == "" ]]
}

if install_everything; then
  echo "Installing everything..."
else
  echo "Custom installation..."
fi

if ! command -v brew &> /dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew is not installed. Instructions at: https://brew.sh"
  exit 1
else
  echo "Homebrew is installed."
  PATH="$PATH:/usr/local/bin:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin"
  set -h
fi

if install_everything || prompt_install "Update Homebrew"; then
  echo "Updating Homebrew..."
  brew update
else
  echo "Skipping Homebrew update."
fi

if install_everything || prompt_install "Git"; then
  echo "Installing Git..."
  brew install git
else
  echo "Skipping Git."
fi

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone --recurse-submodules https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy || exit 1
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
  git submodule update --init --recursive
fi
cd - || exit 1

RA_PATH=~/.local/share/rails-academy

source "$RA_PATH/common/install_helpers.sh"

if xcode-select -p &> /dev/null; then
  good "Xcode Command Line Tools are installed."
else
  INSTRUCTIONS_URL="https://github.com/justintanner/rails-academy/blob/stable/mac/README.md"
  bad "Xcode Command Line Tools are NOT installed. Instructions: " $INSTRUCTIONS_URL 1
fi

echo "Setting git defaults..."
source "$RA_PATH/common/install/terminal/set-git.sh"

brew_packages=(
  fzf ripgrep bash bat eza zoxide btop httpd fastfetch fd gh tldr
  ruby-build bash-completion imagemagick vips libpq mysql-client sqlite3 1password-cli
  font-hack-nerd-font font-jetbrains-mono-nerd-font chromedriver
)

for package in "${brew_packages[@]}"; do
  if install_everything || prompt_install "${package}"; then
    echo "Installing ${package}..."
    brew install "${package}"
  else
    echo "Skipping ${package}."
  fi
done

if install_everything || prompt_install "Terraform"; then
  echo "Installing Terraform..."
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
else
  echo "Skipping Terraform."
fi

# Format: "cask:App Name" (App Name matches the name in /Applications)
apps=(
  "docker:Docker"
  "alacritty:Alacritty"
  "1password:1Password"
  "rubymine:RubyMine"
  "vscode:Visual Studio Code"
  "google-chrome:Google Chrome"
  "zoom:zoom.us"
)

for app_pair in "${apps[@]}"; do
  app="${app_pair%%:*}"
  app_name="${app_pair##*:}"

  if install_everything || prompt_install "${app_name}"; then
    if [ -e "/Applications/${app_name}.app" ]; then
      echo "${app_name} is already installed."
    else
      echo "Installing ${app_name}..."
      brew install --cask "${app}"
      xattr -dr com.apple.quarantine "/Applications/${app_name}.app"
    fi
  else
    echo "Skipping ${app_name}."
  fi
done

if command -v mise &> /dev/null; then
  good "Mise is installed."
else
  echo "Installing Mise..."
  source "$RA_PATH/mac/bash/deps"
  curl https://mise.run | sh
  PATH=$PATH:~/.local/bin
  mise activate
fi

if [ -f /usr/local/bin/rubymine ]; then
  good "Rubymine shell script installed."
else
  echo "Installing \"rubymine\" shell script..."
  sudo cp ~/.local/share/rails-academy/mac/rubymine /usr/local/bin/rubymine
  sudo chmod +x /usr/local/bin/rubymine
fi

echo "Installing gitstatus..."
source "$RA_PATH/common/install/terminal/gitstatus.sh"

echo -e "\nInstalling config files..."
install_only_if_missing $RA_PATH/common/alacritty-light.toml ~/.alacritty.toml
install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables

if install_everything || prompt_install "Modify (and backup existing) bash config files"; then
  install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
  install_and_backup_old_file $RA_PATH/mac/.bashrc ~/.bashrc
  install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
  install_and_backup_old_file $RA_PATH/commmon/defaults/bash/inputrc ~/.inputrc
fi

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling the first Rails Academy lesson..."
source "$RA_PATH/common/install_lessons.sh"

if install_everything || prompt_install "Set bash as the default terminal"; then
  echo "Setting bash as the default terminal..."
  chsh -s /opt/homebrew/bin/bash
  defaults write com.apple.Terminal Shell -string "/opt/homebrew/bin/bash"
fi

echo "Setting fonts in Terminal..."
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "JetBrainsMonoNF-Regular"'
osascript -e 'tell application "Terminal" to set font size of settings set "Basic" to 14'

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal."
