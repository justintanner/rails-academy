echo -e "Installing Rails Academy on a Mac...\n"

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

echo "Updating Homebrew..."
brew update

echo "Installing Git..."
brew install git

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
mkdir -p ~/.local/share/rails-academy
git clone https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy
if [[ $RAILS_ACADEMY_REF != "main" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
fi
cd -
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
  ruby-build bash-completion imagemagick vips libpq mysql-client sqlite3
  font-hack-nerd-font font-jetbrains-mono-nerd-font
)

for package in "${brew_packages[@]}"; do
  echo "Installing ${package}..."
  brew install "${package}"
done

echo "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraformx

apps=(
  "docker:Docker"
  "rubymine:RubyMine"
  "vscode:Visual Studio Code"
)

for app_pair in "${apps[@]}"; do
  app="${app_pair%%:*}"
  app_name="${app_pair##*:}"

  if [ ! -e "/Applications/${app_name}.app" ]; then
    echo "Installing ${app_name}..."
    brew install --cask "${app}"
    xattr -dr com.apple.quarantine "/Applications/${app_name}.app"
  else
    echo "${app_name} is already installed."
  fi
done

echo "Installing / Updating Alacritty..."
brew install --cask alacritty
xattr -dr com.apple.quarantine "/Applications/Alacritty.app"

if ! command -v mise &> /dev/null; then
  echo "Installing Mise..."
  source "$RA_PATH/mac/bash/deps"
  curl https://mise.run | sh
  PATH=$PATH:~/.local/bin
  mise activate
fi

if [ ! -f /usr/local/bin/rubymine ]; then
  echo "Installing \"rubymine\" shell script..."
  sudo cp ~/.local/share/rails-academy/mac/rubymine /usr/local/bin/rubymine
  sudo chmod +x /usr/local/bin/rubymine
fi

echo "Installing gitstatus..."
source "$RA_PATH/common/install/terminal/gitstatus.sh"

echo -e "\nInstalling config files..."
install_and_backup_old_file $RA_PATH/mac/alacritty.toml ~/.alacritty.toml

install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables

install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
install_and_backup_old_file $RA_PATH/mac/.bashrc ~/.bashrc
install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
install_and_backup_old_file $RA_PATH/common/defaults/bash/inputrc ~/.inputrc

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling the Rails Academy lessons..."
source "$RA_PATH/common/install_lessons.sh"

echo "Setting bash as the default terminal..."
chsh -s /opt/homebrew/bin/bash
defaults write com.apple.Terminal Shell -string "/opt/homebrew/bin/bash"

echo "Setting fonts in Terminal..."
osascript -e 'tell application "Terminal" to set font name of settings set "Basic" to "JetBrainsMonoNF-Regular"'
osascript -e 'tell application "Terminal" to set font size of settings set "Basic" to 14'

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your Terminal to apply all changes."
