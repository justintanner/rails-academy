if [ -d ~/mnt/c/Users ]; then
  # Must be on WSL on Windows
  windows_username=$(echo $PATH | grep -oP '/mnt/c/Users/\K[^/]+')
  mkdir -p /mnt/c/Users/$windows_username/ralessons
  ln -s /mnt/c/Users/$windows_username/ralessons ~/ralessons
else
  mkdir -p ~/ralessons
fi

if [ -d ~/ralessons/ra-101 ]; then
  echo "RA-101 already exists. Skipping..."
else
  git clone https://github.com/justintanner/ra-101 ~/ralessons
fi

