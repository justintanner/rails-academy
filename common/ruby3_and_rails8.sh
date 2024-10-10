ruby_version=$(ruby --version | awk '{print $2}')

if version_lt "$ruby_version" "3.3.0"; then
  echo "Installing ruby 3.3 as the default..."
  mise use --global ruby@3.3
else
  echo "Ruby 3.3 already installed."
fi

if command -v ruby &>/dev/null; then
  version_lt() {
    ruby -e "v1 = Gem::Version.new('$1'); v2 = Gem::Version.new('$2'); exit(v1 < v2 ? 0 : 1)"
  }

  rails_version=$(rails --version | awk '{print $2}')

  if version_lt "$rails_version" "8.0.0beta1"; then
    echo "Installing rails8..."
    mise x ruby -- gem install rails --no-document -v ">= 8.0.0beta1"
  else
    echo "Rails 8 already installed."
 fi
fi


