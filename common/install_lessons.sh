if [ -d /mnt/c/Users ]; then
  echo "Symlinking ralessons to the Windows home dir...."
  windows_username=$(echo $PATH | grep -oP '/mnt/c/Users/\K[^/]+')
  mkdir -p /mnt/c/Users/$windows_username/ralessons
  ln -sf /mnt/c/Users/$windows_username/ralessons ~/ralessons
else
  mkdir -p ~/ralessons
fi

if [ -d ~/ralessons/ra-101 ]; then
  echo "RA-101 already exists. Skipping..."
else
  git clone https://github.com/justintanner/ra-101 ~/ralessons/ra-101
fi

