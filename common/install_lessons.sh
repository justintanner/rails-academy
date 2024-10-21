if [ -d /mnt/c/Users ]; then
  echo "Symlinking lessons to the Windows home dir...."
  windows_username=$(echo $PATH | grep -oP '/mnt/c/Users/\K[^/]+')
  mkdir -p /mnt/c/Users/$windows_username/lessons
  ln -sf /mnt/c/Users/$windows_username/lessons ~/lessons
else
  mkdir -p ~/lessons
fi

if [ -d ~/lessons/ra-101 ]; then
  echo "RA-101 already exists. Skipping..."
else
  git clone https://github.com/justintanner/ra-101 ~/lessons/ra-101
fi

