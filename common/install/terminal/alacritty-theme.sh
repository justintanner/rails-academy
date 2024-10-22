DEST=~/.local/share/alacritty-theme
rm -rf $DEST
mkdir -p $DEST
git clone --depth=1 https://github.com/alacritty/alacritty-theme.git $DEST
