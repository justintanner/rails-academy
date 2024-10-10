DEST="$HOME/.local/share/gitstatus"
mkdir -p $DEST
git clone --depth=1 https://github.com/romkatv/gitstatus.git $DEST
echo 'source ~/gitstatus/gitstatus.prompt.sh' >> ~/.bashrc
