#!/bin/bash

echo -e "Installing Rails Academy on a Mac...\n"

if ! command -v brew &> /dev/null; then
  # Homebrew might not be in path yet try to inject it.
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

echo "Updating updating Homebrew package..."
brew update

if command -v git &> /dev/null; then
  echo "Git is installed."
else
  echo "Git not installed. Installing..."
  brew install git
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

OMAKUB_SUB_PATH=~/.local/share/rails-academy/vendor/omakub
RA_PATH=~/.local/share/rails-academy

echo "Loading bash helpers..."
source "$RA_PATH/common/install_helpers.sh"

if xcode-select -p &> /dev/null; then
  good "Xcode Command Line Tools are installed."
else
  INSTRUCTIONS_URL="https://github.com/justintanner/rails-academy/blob/stable/mac/README.md"
  bad "Xcode Command Line Tools are NOT installed. Instructions: " $INSTRUCTIONS_URL 1
fi

echo "Setting git defaults..."
source "$OMAKUB_SUB_PATH/install/terminal/set-git.sh"

echo "Installing multiple Homebrew packages..."
brew install \
  fzf ripgrep bash bat eza zoxide btop httpd fastfetch fd gh tldr \
  ruby-build bash-completion imagemagick vips libpq mysql-client sqlite3 1password-cli \
  font-hack-nerd-font font-jetbrains-mono-nerd-font chromedriver

if command -v terraform &> /dev/null; then
  good "Terraform is installed."
else
  echo "Installing Terraform..."
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
fi

# Format: "cask:App Name" (App Name matches the name in /Applications)
apps=(
  "docker:Docker"
  "alacritty:Alacritty"
  "1password:1Password"
  "rubymine:RubyMine"
  "google-chrome:Google Chrome"
  "zoom:zoom.us"
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
install_only_if_missing $RA_PATH/mac/.alacritty.toml ~/.alacritty.toml
install_only_if_missing $RA_PATH/common/.op_load_env ~/.op_load_env
install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables
install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
install_and_backup_old_file $RA_PATH/mac/.bashrc ~/.bashrc
install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
install_and_backup_old_file $OMAKUB_SUB_PATH/defaults/bash/inputrc ~/.inputrc

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling the first Rails Academy lesson..."
source "$RA_PATH/common/install_lessons.sh"

echo -e "\nSetting bash as the default terminal..."
chsh -s /opt/homebrew/bin/bash
defaults write com.apple.Terminal Shell -string "/opt/homebrew/bin/bash"

echo "Setting fonts in Terminal..."
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "JetBrainsMonoNF-Regular"'
osascript -e 'tell application "Terminal" to set font size of settings set "Basic" to 14'

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal."
