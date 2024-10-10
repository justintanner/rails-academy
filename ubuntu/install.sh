#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMAKUB_SUB_PATH="$SCRIPT_PATH/vendor/omakub"

echo -e "Installing Rails Academy...\n"

echo "Updating package lists..."
sudo apt update -y

if command -v git >/dev/null 2>&1; then
  good "Git is installed."
else
  echo "Git not installed. Installing..."
  apt install -y git
fi

echo "Setting git defaults..."
source "$OMAKUB_SUB_PATH/install/terminal"

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone --recurse-submodules https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
  git submodule update --init --recursive
fi
cd -

RA_PATH=$HOME/.local/share/rails-academy

echo "Loading bash helpers..."
source "$RA_PATH/common/install_helpers.sh"

echo "Installing command line utils..."
sudo apt install -y fzf ripgrep bat eza zoxide plocate btop apache2-utils fd-find tldr

if command -v terraform >/dev/null 2>&1; then
  good "Terraform is installed."
else
  echo "Installing Terraform..."
  source "$RA_PATH/install/terminal/terraform.sh"
fi

if command -v mise >/dev/null 2>&1; then
  good "Mise is installed."
else
  echo "Installing Mise..."
  source "$OMAKUB_SUB_PATH/install/terminal/mise.sh"
fi

echo -e "\nInstalling config files..."
install_only_if_missing ~/.local/share/rails-academy/mac/.alacritty.toml ~/.alacritty.toml
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
