echo "Installing ruby 3.3 as the default..."
mise use --global ruby@3.3

echo "Installing rails8..."
mise x ruby -- gem install rails --no-document -v ">= 8.0"

echo "Installing kamal..."
mise x ruby -- gem install kamal --no-document

echo "Installing rubocop..."
mise x ruby -- gem install rubocop --no-document
