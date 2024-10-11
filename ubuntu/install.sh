#!/bin/bash
set -e

echo -e "Installing Rails Academy on Ubuntu...\n"

echo "Updating package lists..."
sudo apt update -y

if command -v git &> /dev/null; then
  echo "Git is installed."
else
  echo "Git not installed. Installing..."
  apt install -y git
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

echo "Install terminal apps and libraries..."
source "$OMAKUB_SUB_PATH/install/terminal/apps-terminal.sh"
source "$OMAKUB_SUB_PATH/install/terminal/libraries.sh"

scripts=(
  "terminal/set-git:git"
  "terminal/app-github-cli:gh"
  "terminal/app-fastfetch:fastfetch"
  "terminal/app-lazydocker:lazydocker"
  "terminal/app-lazygit:lazygit"
)

for script in "${scripts[@]}"; do
  script="${script_app%%:*}"
  app="${script_app##*:}"
  if command -v $app &> /dev/null; then
    good "$app is installed."
  else
    echo "Installing $app..."
    source "$OMAKUB_SUB_PATH/install/$script.sh"
  fi
done

# Don't want to rerun mise installs
if command -v mise &> /dev/null; then
  good "Mise is installed."
else
  echo "Installing Mise..."
  source "$OMAKUB_SUB_PATH/install/terminal/mise.sh"
fi

# Format script_path:terminal_name
script_apps=(
  "terminal/docker:docker"
  "desktop/app-chrome:google-chrome"
  "desktop/optional/app-1password:1password"
  "desktop/optional/app-rubymine:rubymine"
  "desktop/optional/app-zoom:zoom"
)

if [ -n "$XDG_CURRENT_DESKTOP" ]; then
  echo "Install desktop apps..."
  for script_app in "${script_apps[@]}"; do
    script="${script_app%%:*}"
    app="${script_app##*:}"
    if command -v $app &> /dev/null; then
      good "$app is installed."
    else
      echo "Installing $app..."
      source "$OMAKUB_SUB_PATH/install/$script.sh"
    fi
  done

  echo "Installing alacritty..."
  sudo apt-get install -y alacritty
else
  echo "Skipping desktop apps..."
fi

if command -v terraform &> /dev/null; then
  good "Terraform is installed."
else
  echo "Installing Terraform..."
  source "$RA_PATH/ubuntu/install/terminal/terraform.sh"
fi

source "$RA_PATH/common/install/terminal/gitstatus.sh"

echo -e "\nInstalling config files..."
install_only_if_missing $RA_PATH/ubuntu/.alacritty.toml ~/.alacritty.toml
install_only_if_missing $RA_PATH/common/.op_load_env ~/.op_load_env
install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables
install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
install_and_backup_old_file $RA_PATH/ubuntu/.bashrc ~/.bashrc
install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
install_and_backup_old_file $OMAKUB_SUB_PATH/defaults/bash/inputrc ~/.inputrc

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling the first Rails Academy lesson..."
source "$RA_PATH/common/install_lessons.sh"

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
