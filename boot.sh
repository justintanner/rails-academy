#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Detected a Mac..."
  eval "curl -fsSL https://raw.githubusercontent.com/justintanner/rails-academy/stable/mac/install.sh | bash -i"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if grep -q "microsoft" /proc/version; then
    echo "Detected WSL on Windows..."
    eval "wget -qO- https://raw.githubusercontent.com/justintanner/rails-academy/stable/ubuntu/install.sh | bash -i"
  else
    echo "Detected Linux..."
    eval "wget -qO- https://raw.githubusercontent.com/justintanner/rails-academy/stable/ubuntu/install.sh | bash -i"
  fi
else
  echo "Unsupported OS: $OSTYPE"
  exit 0
fi
