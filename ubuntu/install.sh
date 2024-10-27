UBUNTU_DESKTOP=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)
WSL=$([[ -d /mnt/c/Users ]] && echo true || echo false)

echo -e "Installing Rails Academy on Ubuntu...\n"

echo "Updating package lists..."
sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Rails Academy..."
rm -rf ~/.local/share/rails-academy
git clone https://github.com/justintanner/rails-academy.git ~/.local/share/rails-academy >/dev/null
cd ~/.local/share/rails-academy
if [[ $RAILS_ACADEMY_REF != "master" ]]; then
  git checkout "${RAILS_ACADEMY_REF:-stable}"
fi
cd -

RA_PATH=~/.local/share/rails-academy

echo "Loading bash helpers..."
source "$RA_PATH/common/install_helpers.sh"

echo "Install terminal apps and libraries..."
source "$RA_PATH/ubuntu/install/terminal/apps-terminal.sh"
source "$RA_PATH/ubuntu/install/terminal/libraries.sh"

if [ "$UBUNTU_DESKTOP" = true ]; then
  if command -v fastfetch &> /dev/null; then
    source "$RA_PATH/ubuntu/install/terminal/app-fastfetch.sh"
  else
    echo "Not installing fastfetch on WSL Linux..."
  fi

  if command -v code &> /dev/null; then
    source "$RA_PATH/ubuntu/install/terminal/app-vscode.sh"
  else
    echo "Not installing VS Code on WSL Linux..."
  fi
fi

terminals=(
  "terminal/set-git:git"
  "terminal/app-github-cli:gh"
  "terminal/app-lazydocker:lazydocker"
  "terminal/app-lazygit:lazygit"
)

for terminal in "${terminals[@]}"; do
  script="${terminal%%:*}"
  app="${terminal##*:}"
  if ! command -v $app &> /dev/null; then
    echo "Installing $app..."
    source "$RA_PATH/ubuntu/install/$script.sh"
  else
    good "$app is installed."
  fi
done

if ! command -v mise &> /dev/null; then
  echo "Installing Mise..."
  source "$RA_PATH/ubuntu/install/terminal/mise.sh"
fi

if [ "$UBUNTU_DESKTOP" = true ]; then
  desktops=(
    "terminal/docker:docker"
    "desktop/optional/app-rubymine:rubymine"
    "defaults/app-vscode:code"
  )

  echo "Installing desktop apps..."
  for desktop in "${desktops[@]}"; do
    script="${desktop%%:*}"
    app="${desktop##*:}"
    if ! command -v $app &> /dev/null; then
      echo "Installing $app..."
      source "$RA_PATH/ubuntu/install/$script.sh"
    else
      good "$app is installed."
    fi
  done
else
  echo "Skipping desktop apps..."
fi

echo "Installing Alacritty..."
sudo apt-get install -y alacritty

if ! command -v terraform &> /dev/null; then
  echo "Installing Terraform..."
  source "$RA_PATH/ubuntu/install/terminal/terraform.sh"
fi

source "$RA_PATH/common/install/terminal/gitstatus.sh"

echo -e "\nInstalling config files..."
if [ "$UBUNTU_DESKTOP" = true ]; then
  install_and_backup_old_file $RA_PATH/ubuntu/alacritty.toml ~/.alacritty.toml
fi

install_only_if_missing $RA_PATH/common/variables ~/.config/rails-academy/variables

install_and_backup_old_file $RA_PATH/common/.bash_profile ~/.bash_profile
install_and_backup_old_file $RA_PATH/ubuntu/.bashrc ~/.bashrc
install_and_backup_old_file $RA_PATH/common/.zshrc ~/.zshrc
install_and_backup_old_file $RA_PATH/common/defaults/bash/inputrc ~/.inputrc

source "$RA_PATH/common/ruby3_and_rails8.sh"

echo -e "\nInstalling Rails Academy lessons..."
source "$RA_PATH/common/install_lessons.sh"

if [ "$WSL" = true ]; then
  echo "Connecting VS Code to WSL..."
  # Install WSL to VS Code extension
  code
fi

echo -e "\n"
good "Successfully installed Rails Academy!\n"
echo "Please restart your terminal to apply the changes."
