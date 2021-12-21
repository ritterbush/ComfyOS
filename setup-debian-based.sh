#!/bin/sh

# Debian Linux-based (e.g. Mint, Ubuntu, DEBIAN!) setup of ComfyOS.
# Run with options -u newusername -p passwordfornewusername, lest the defaults be used.
# Or run with -c  and -p passwordofcurrentuser to use the current user, and possibly overwrite some config files.

username=gnuslashdebianlinux
password=password

while getopts ":u:p:c" opt; do
  case ${opt} in
    u ) username=${OPTARG}
      ;;
    p ) password=${OPTARG}
      ;;
    c ) username=${USER}
      ;;
  esac
done

if [ $username != ${USER} ] # -c option is not used
then
# Create new user with given password and add user to wheel, audio, and video groups
sudo useradd -m -G sudo,audio,video "$username"
(echo "$password"; echo "$password") | sudo passwd "$username"
sudo chmod 733 /home/"$username"
fi # end of -c option is not used


# Nothing with running as $username seems to be working like I want, so just temporarily change permissions for executing/writing to new user's home folder:

cat > /home/${username}/new-user-setup.sh <<End-of-message
(echo "$password"; echo; echo; echo) | sudo -S apt install xorg xinit zsh git firefox feh sxiv imagemagick fonts-linuxlibertine neofetch htop mpd ncmpcpp libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson libxext-dev asciidoc cmake python3 python3-pip ninja-build libxinerama-dev

# Removed from above: suckless-tools libxft2-dev libpcre3 pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev


# Install Alacritty by adding a PPA repository
(echo "$password") | sudo -S add-apt-repository ppa:mmstick76/alacritty -y
(echo "$password") | sudo -S apt update
(echo "$password") | sudo -S apt install alacritty

# Directory for programs not from repos
mkdir -p ~/Programs

# Install Neovim Appimage for Latest Release
# ref: https://github.com/neovim/neovim/wiki/Installing-Neovim
mkdir ~/Programs/neovim
cd ~/Programs/neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
# Below we will alias 'nvim' in ~/.zshrc to execute this Appimage

# Build/Install picom
cd ~/Programs
git clone https://github.com/yshui/picom
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
(echo "$password") | sudo -S ninja -C build install

# Build/Install py-wal
cd ~/Programs
git clone https://github.com/dylanaraps/pywal
cd pywal
pip3 install --user .

# Add local 'pip' to PATH:
# (In your .bashrc, .zshrc etc)
#export PATH="${PATH}:${HOME}/.local/bin/"
# Also new user, if used
#if [ $username != ${USER} ] # -c option is not used
#then
#export PATH="${PATH}:home/${username}/.local/bin/"
#fi

# Install latest stable Exa
mkdir -p ~/Programs/exa
cd ~/Programs/exa
wget -c https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
unzip exa-linux-x86_64-v0.10.1.zip
sudo mv ~/Programs/exa/bin/exa  /usr/local/bin/
sudo cp ~/Programs/exa/completions/exa.zsh /usr/local/share/zsh/site-functions/_exa

# Download Fall wallpaper from Pexels under CC0 license
mkdir -p ~/Pictures/Wallpapers
#fall
curl https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg > ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
#winter
curl https://images.pexels.com/photos/688660/pexels-photo-688660.jpeg > ~/Pictures/Wallpapers/winter-snow-season.jpg
#spring
curl https://images.pexels.com/photos/570041/pexels-photo-570041.jpeg > ~/Pictures/Wallpapers/spring-flower-season.jpg
#summer
curl https://images.pexels.com/photos/7084186/pexels-photo-7084186.jpeg > ~/Pictures/Wallpapers/summer-sand-season.jpg

# Generate py-wal cache files before building dwm and dmenu
/home/${username}/.local/bin/wal -i ~/Pictures/Wallpapers/winter-snow-season.jpg
sleep 3

# Directory for building programs from source
mkdir -p ~/Programs/files

# Get my dwm/dmenu desktop environment, various dotfiles, and scripts
git clone https://github.com/ritterbush/files ~/Programs/files

# Put dwm and dmenu in a good spot
mv ~/Programs/files/dwm ~/Programs/
mv ~/Programs/files/dmenu ~/Programs/

# Copy start file for login managers
sed -i "s/FFFFF/$username/" ~/Programs/files/dwm.desktop
echo "$password" | sudo -S cp ~/Programs/files/dwm.desktop /usr/share/xsessions/dwm.desktop

# xinitrc
cp ~/Programs/files/.xinitrc ~/.xinitrc
# link it to .xsession
ln -s ~/.xinitrc ~/.xsession

# zshrc
cp ~/Programs/files/.zshrc ~/.zshrc

# Set Neovim Appimage alias
sed -i "s/^alias music=.*$/&\\nFFFFF/" ~/.zshrc
sed -i "s|^FFFFF|alias nvim=\'~/Programs/neovim/nvim.appimage\'|" ~/.zshrc

# change shell to zsh
(echo "$password"; echo /bin/zsh) | chsh 

# shell scripts, neovim config and plugins, alacritty config 
cp -r ~/Programs/files/.local ~/
cp -r ~/Programs/files/.config ~/

# picom compositor config
mkdir -p ~/.config/picom
cp /etc/xdg/picom.conf.example ~/.config/picom/picom.conf

# Setup colors and opacity, and these also build and install dwm and dmenu
# Run again with different numbers to change
~/.local/bin/alacritty-opacity.sh 70
#~/.local/bin/dwm-opacity.sh 70
sed -i "s/static const unsigned int baralpha = .*/static const unsigned int baralpha = 0xb3;/" ~/Programs/dwm/config.def.h
#~/.local/bin/wallpaper-and-colors.sh ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
sed -i "5s|.*|filepath=~/Pictures/Wallpapers/winter-snow-season.jpg|" ~/.local/bin/wallpaper-and-colors.sh
#xwallpaper --zoom ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
#nitrogen --random ~/Pictures/Wallpapers/
sed -i "s/static const char norm_fg\[\] = .*/\$(sed -n 1p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/static const char norm_bg\[\] = .*/\$(sed -n 2p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/static const char norm_border\[\] = .*/\$(sed -n 3p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/static const char sel_fg\[\] = .*/\$(sed -n 5p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/static const char sel_bg\[\] = .*/\$(sed -n 6p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/static const char sel_border\[\] = .*/\$(sed -n 7p ~/.cache/wal/colors-wal-dwm.h)/" ~/Programs/dwm/config.def.h
sed -i "s/^.*\[SchemeNorm\].*/\$(sed -n 3p ~/.cache/wal/colors-wal-dmenu.h)/" ~/Programs/dmenu/config.def.h
sed -i "s/^.*\[SchemeSel\].*/\$(sed -n 4p ~/.cache/wal/colors-wal-dmenu.h)/" ~/Programs/dmenu/config.def.h
sed -i "s/^.*\[SchemeOut\].*/\$(sed -n 5p ~/.cache/wal/colors-wal-dmenu.h)/" ~/Programs/dmenu/config.def.h
colorNewHighlight=\$(sed -n 7p ~/.cache/wal/colors)
colorNewHighlight=\$(echo "\$colorNewHighlight" | sed "s/^/\"/")
colorNewHighlight=\$(echo "\$colorNewHighlight" | sed "s/\$/\"/")
color2=\$(grep "\[SchemeSel\] =" ~/Programs/dmenu/config.def.h)
color2=\$(echo "\$color2" | sed "s/^.*, //")
color2=\${color2% \},}
color3=\$(grep "\[SchemeNorm\] =" ~/Programs/dmenu/config.def.h)
color3=\$(echo "\$color3" | sed "s/^.*, //")
color3=\${color3% \},}
sed -i "s/^.*\[SchemeSelHighlight\] =.*/        \[SchemeSelHighlight\] = \{ \${colorNewHighlight}, \${color2} \},/" ~/Programs/dmenu/config.def.h
sed -i "s/^.*\[SchemeNormHighlight\] =.*/        \[SchemeNormHighlight\] = \{ \${colorNewHighlight}, \${color3} \},/" ~/Programs/dmenu/config.def.h
cd /home/"$username"/Programs/dwm/ && sudo -S make clean install
cd /home/"$username"/Programs/dmenu/ && sudo -S make clean install
#wal -i ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
End-of-message

# Make that script executable by owner
(echo "$password") | sudo -S chmod 700 /home/"$username"/new-user-setup.sh

#echo "$password" | sudo -S su - "$username" -c "sh /home/"$username"/new-user-setup.sh

if [ $username != ${USER} ] # -c option is not used
then
# Change owner to be new user
sudo -S chown "$username:$username" /home/"$username"/new-user-setup.sh

# Return permissions to new user's home directory
sudo -S chmod 700 /home/"$username"
fi

# Execute script as new or current user
(echo "$password") | sudo -S su - "$username" -c "sh /home/"$username"/new-user-setup.sh"

# Replace password from script with PASSWORD12345
(echo "$password") | sudo -S sed -i "s/$password/PASSWORD12345/g" /home/"$username"/new-user-setup.sh

#sudo -S su - "$username" -c "wal -i ~/Pictures/Wallpapers/fall-autumn-red-season.jpg"

#sudo -S su - "$username" -c "xwallpaper --zoom ~/Pictures/Wallpapers/fall-autumn-red-season.jpg"
#xwallpaper --zoom ~/Pictures/Wallpapers/fall-autumn-red-season.jpg

echo done
