#!/bin/bash

echo -e "Installing Rails Academy...\n"

echo "Updating package lists..."
sudo apt update -y

if command -v git >/dev/null 2>&1; then
  good "Git is installed."
else
  echo "Git not installed. Installing..."
  apt install -y git
fi

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone --recurse-submodules https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
  git submodule update --init --recursive
fi
cd -

OMAKUB_SUB_PATH="$HOME/.local/share/rails-academy/vendor/omakub"
RA_PATH=$HOME/.local/share/rails-academy

echo "Loading bash helpers..."
source "$RA_PATH/common/install_helpers.sh"

scripts=(
  "set-git",
  "app-terminal",
  "app-mise",
  "app-fastfetch",
  "app-lazydocker",
  "app-lazygit",
  "app-github-cli",
  "docker",
  "libraries"
  "mise"
)

for script in "${scripts[@]}"; do
  source "$OMAKUB_SUB_PATH/install/terminal/$script.sh"
done

apps=(
  "app-chrome"
  "optional/app-1password"
  "optional/app-rubymine"
  "optional/app-zoom"
)

for app in "${apps[@]}"; do
  if [ -n "$XDG_CURRENT_DESKTOP" ]; then
   source "$OMAKUB_SUB_PATH/install/desktop/$script.sh"
 fi
done

if [ -n "$XDG_CURRENT_DESKTOP" ]; then
  echo "Installing alacritty..."
  apt-get install y alacritty
fi

if command -v terraform >/dev/null 2>&1; then
  good "Terraform is installed."
else
  echo "Installing Terraform..."
  source "$RA_PATH/install/terminal/terraform.sh"
fi

echo -e "\nInstalling config files..."
install_only_if_missing ~/.local/share/rails-academy/mac/.alacritty.toml ~/.alacritty.toml
install_only_if_missing ~/.local/share/rails-academy/mac/.op_load_env ~/.op_load_env
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bash_profile ~/.bash_profile
install_and_backup_old_file ~/.local/share/rails-academy/mac/.bashrc ~/.bashrc
install_and_backup_old_file ~/.local/share/rails-academy/mac/.zshrc ~/.zshrc
install_and_backup_old_file ~/.local/share/rails-academy/mac/bash/inputrc ~/.inputrc

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
