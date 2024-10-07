#!/bin/bash

fail() {
  local app=$1
  local url=${2:-"wget -o0- rails.academy/install | bash"}
  echo "Error: ${app} is not installed. Instructions:"
  echo "${url}"
  exit 1
}

if xcode-select -p >/dev/null 2>&1; then
  echo "Xcode CLI is installed."
else
  fail "Xcode CLI" "https://github.com/justintanner/mac/README.md#xcode"
fi

if docker info >/dev/null 2>&1; then
  echo "Docker is running."
else
  fail "Docker" "https://github.com/justintanner/mac/README.md#docker"
fi

if [ -d /Applications/Alacritty.app ]; then
  echo "Alacritty is installed."
else
  fail "Alacritty" "https://github.com/justintanner/mac/README.md#alacritty"
fi

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is installed."
else
  fail "Homebrew"
fi

if command -v git >/dev/null 2>&1; then
  echo "Git is installed."
else
  fail "Git"
fi

if [ -d ~/.local/share/rails-academy ]; then
  echo "Rails Academy repository is cloned."
else
  fail "Rails Academy Repository"
fi

if command -v mise >/dev/null 2>&1; then
  echo "Mise is installed."
else
  fail "Mise"
fi

if command -v terraform >/dev/null 2>&1; then
  echo "Terraform is installed."
else
  fail "Terraform"
fi

# Check for required Homebrew packages
packages=(fzf ripgrep bat eza zoxide btop httpd fd tldr ruby-build bash-completion bash-git-prompt imagemagick vips libpq mysql-client 1password-cli)

for package in "${packages[@]}"; do
  if brew list -1 | grep -q "^${package}\$"; then
    echo "${package} is installed."
  else
    fail "Homebrew package ${package}"
  fi
done

# Check for required Homebrew cask apps
casks=(font-hack-nerd-font font-jetbrains-mono-nerd-font chromedriver)

for cask in "${casks[@]}"; do
  if brew list --cask -1 | grep -q "^${cask}\$"; then
    echo "${cask} is installed."
  else
    fail "Homebrew cask ${cask}"
  fi
done

echo -e "\n\nVerified! All good!\n"
