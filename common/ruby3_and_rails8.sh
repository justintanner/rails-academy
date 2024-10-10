version_lt() {
  [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" = "$1" ] && [ "$1" != "$2" ]
}

ruby_version=$(ruby --version | awk '{print $2}')

if version_lt "$ruby_version" "3.3.0"; then
  echo "Installing ruby 3.3 as the default..."
  mise use --global ruby@3.3
else
  echo "Ruby 3.3 already installed."
fi

rails_version=$(rails --version | awk '{print $2}')

if version_lt "$rails_version" "8.0.0beta1"; then
  echo "Installing rails8..."
  mise x ruby -- gem install rails --no-document -v ">= 8.0.0beta1"
else
  echo "Rails 8 already installed."
fi
