FONT_NAME="JetBrainsMono Nerd Font"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
FILE_NAME="${FONT_NAME/ Nerd Font/}"

cd /tmp
wget -O "$FILE_NAME.zip" "$URL"
unzip "$FILE_NAME.zip" -d "$FILE_NAME"
mkdir -p ~/.loca/share/fonts
cp "$FILE_NAME"/*.ttf ~/.local/share/fonts
rm -rf "$FILE_NAME.zip" "$FILE_NAME"
fc-cache -fv
cd -
clear
