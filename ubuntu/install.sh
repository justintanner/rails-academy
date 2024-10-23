#!/usr/bin/env bash
set -e

UBUNTU_DESKTOP=false
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
  UBUNTU_DESKTOP=true
fi

echo -e "Installing Rails Academy on Ubuntu...\n"
read -n 1 -s -r -p "Press any key to continue..."

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

echo "Updating package lists..."
sudo apt update -y

if install_everything || prompt_install "Git"; then
  if command -v git &> /dev/null; then
    echo "Git is already installed."
  else
    echo "Git not installed. Installing..."
    sudo apt install -y git
  fi
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

echo "Loading bash helpers..."
source "$RA_PATH/common/install_helpers.sh"

echo "Install terminal apps and libraries..."
source "$RA_PATH/ubuntu/install/terminal/apps-terminal.sh"
source "$RA_PATH/ubuntu/install/terminal/libraries.sh"

if [ "$UBUNTU_DESKTOP" = true ] && (install_everything || prompt_install "Fastfetch"); then
  if command -v fastfetch &> /dev/null; then
    source "$RA_PATH/ubuntu/install/terminal/app-fastfetch.sh"
  else
    echo "Not installing fastfetch on WSL Linux..."
  fi
fi

if [ "$UBUNTU_DESKTOP" = true ] && (install_everything || prompt_install "Visual Studio Code"); then
  if command -v code &> /dev/null; then
    source "$RA_PATH/ubuntu/install/terminal/app-vscode.sh"
  else
    echo "Not installing VS Code on WSL Linux..."
  fi
fi

# Format script_path:terminal_name
terminals=(
  "terminal/set-git:git"
  "terminal/app-github-cli:gh"
  "terminal/app-lazydocker:lazydocker"
  "terminal/app-lazygit:lazygit"
)

for terminal in "${terminals[@]}"; do
  script="${terminal%%:*}"
  app="${terminal##*:}"
  if install_everything || prompt_install "${app}"; then
    if command -v $app &> /dev/null; then
      good "$app is installed."
    else
      echo "Installing $app..."
      source "$RA_PATH/ubuntu/install/$script.sh"
    fi
  else
    echo "Skipping ${app}."
  fi
done

if command -v mise &> /dev/null; then
  good "Mise is installed."
else
  if install_everything || prompt_install "Mise"; then
    echo "Installing Mise..."
    source "$RA_PATH/install/terminal/mise.sh"
  else
    echo "Skipping Mise."
  fi
fi

# Format script_path:terminal_name
desktops=(
  "terminal/docker:docker"
  "desktop/app-chrome:google-chrome"
  "desktop/optional/app-1password:1password"
  "desktop/optional/app-rubymine:rubymine"
  "desktop/optional/app-zoom:zoom"
)

if [ "$UBUNTU_DESKTOP" = true ]; then
  echo "Installing desktop apps..."
  for desktop in "${desktops[@]}"; do
    script="${desktop%%:*}"
    app="${desktop##*:}"
    if install_everything || prompt_install "${app}"; then
      if command -v $app &> /dev/null; then
        good "$app is installed."
      else
        echo "Installing $app..."
        source "$RA_PATH/ubuntu/install/$script.sh"
      fi
    else
      echo "Skipping ${app}."
    fi
  done
else
  echo "Skipping desktop apps..."
fi

if install_everything || prompt_install "Alacritty"; then
  echo "Installing Alacritty..."
  sudo apt-get install -y alacritty
else
  echo "Skipping Alacritty."
fi

if command -v terraform &> /dev/null; then
  good "Terraform is installed."
else
  if install_everything || prompt_install "Terraform"; then
    echo "Installing Terraform..."
    source "$RA_PATH/ubuntu/install/terminal/terraform.sh"
  else
    echo "Skipping Terraform."
  fi
fi

source "$RA_PATH/common/install/terminal/gitstatus.sh"

echo -e "\nInstalling config files..."
install_only_if_missing $RA_PATH/common/alacritty-light.toml ~/.alacritty.toml
install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables

if install_everything || prompt_install "Modify (and backup existing) bash config files"; then
  install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
  install_and_backup_old_file $RA_PATH/ubuntu/.bashrc ~/.bashrc
  install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
  install_and_backup_old_file $RA_PATH/common/defaults/bash/inputrc ~/.inputrc
fi

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling the first Rails Academy lesson..."
source "$RA_PATH/common/install_lessons.sh"

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
