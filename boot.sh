if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Detected a Mac..."
  eval "curl -fsSL https://raw.githubusercontent.com/justintanner/rails-academy/stable/mac/install.sh | bash"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Detected Linux..."
  eval "wget -qO- https://raw.githubusercontent.com/justintanner/rails-academy/stable/ubuntu/install.sh | bash"
else
  echo "Unsupported OS: $OSTYPE"
  exit 0
fi
