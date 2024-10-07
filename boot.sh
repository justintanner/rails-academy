#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Detected a Mac..."
  INSTALL_URL="https://raw.githubusercontent.com/justintanner/rails-academy/stable/mac/install.sh"
  eval "bash <(curl -fsSL ${INSTALL_URL} || wget -qO- $(INSTALL_URL))"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if grep -q "microsoft" /proc/version; then
    echo "Detected Windows Subsystem for Linux..."
    echo "Install script coming soon"
  else
    echo "Detected a Linux..."
    echo "Install script coming soon"
  fi
else
  echo "Unsupported OS: $OSTYPE"
  exit 0
fi
