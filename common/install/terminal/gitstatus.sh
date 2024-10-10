DEST="$HOME/.local/share/gitstatus"
rm -rf $DEST
mkdir -p $DEST
git clone --depth=1 https://github.com/romkatv/gitstatus.git $DEST
echo 'source ~/gitstatus/gitstatus.prompt.sh' >> ~/.bashrc
