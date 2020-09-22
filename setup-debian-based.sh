#!/bin/sh

# Non-destructive, Debian Linux-based (e.g. Mint, Ubuntu, DEBIAN!) setup of ComfyOS.
# Creates a new user for setup.
# Run with options -u newusername -p passwordfornewusername, lest the defaults be used.

username=gnuslashdebianlinux
password=password

while getopts ":u:p:" opt; do
  case ${opt} in
    u ) username=${OPTARG}
      ;;
    p ) password=${OPTARG}
      ;;
  esac
done

# Create new user with given password and add user to wheel, audio, and video groups
sudo useradd -m -G wheel,audio,video "$username"
(echo "$password"; echo "$password") | sudo passwd "$username"

# Nothing with running as $username seems to be working like I want, so just temporarily change permissions for executing/writing to new user's home folder:

sudo chmod 733 /home/"$username"

cat > /home/${username}/new-user-setup.sh <<End-of-message
(echo "$password"; echo; echo; echo) | sudo -S apt install xorg xinit zsh git neovim firefox-esr feh sxiv fonts-libertine neofetch htop mpd ncmpcpp
# Alacritty needs to be built, and so does picom and python-pywal, --see github pages for all dependencies!!
# Download Fall wallpaper from Pexels under CC0 license
mkdir -p ~/Pictures/Wallpapers
curl https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg > ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
# Generate py-wal cache files before building dwm and dmenu
wal -i ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
sleep 3
# Directory for building programs from source
mkdir ~/Programs
# Get my dwm/dmenu desktop environment, various dotfiles, and scripts
git clone https://github.com/ritterbush/files ~/Programs/
# xinitrc
cp ~/Programs/.xinitrc ~/.xinitrc
# zshrc
cp ~/Programs/.zshrc ~/.zshrc
# change shell to zsh
(echo "$password"; echo /bin/zsh) | chsh 
# shell scripts, neovim config and plugins, alacritty config 
cp -r ~/Programs/.local ~/
cp -r ~/Programs/.config ~/
# picom compositor config
mkdir -p ~/.config/picom
cp /etc/xdg/picom.conf.example ~/.config/picom/picom.conf
# Setup colors and opacity, and these also build and install dwm and dmenu
# Run again with different numbers to change
~/.local/bin/alacritty-opacity.sh 70
#~/.local/bin/dwm-opacity.sh 70
sed -i "s/static const unsigned int baralpha = .*/static const unsigned int baralpha = 0xb3;/" ~/Programs/dwm/config.def.h
#~/.local/bin/wallpaper-and-colors.sh ~/Pictures/Wallpapers/fall-autumn-red-season.jpg
sed -i "5s|.*|filepath=~/Pictures/Wallpapers/fall-autumn-red-season.jpg|" ~/.local/bin/wallpaper-and-colors.sh
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
chmod 700 /home/"$username"/new-user-setup.sh

#echo "$password" | sudo -S su - "$username" -c "sh /home/"$username"/new-user-setup.sh

# Change owner to be new user
sudo chown "$username:$username" /home/"$username"/new-user-setup.sh

# Return permissions to new user's home directory
sudo chmod 700 /home/"$username"

# Execute script  as new user
sudo -S su - "$username" -c "sh /home/"$username"/new-user-setup.sh"

#sudo -S su - "$username" -c "wal -i ~/Pictures/Wallpapers/fall-autumn-red-season.jpg"

#sudo -S su - "$username" -c "xwallpaper --zoom ~/Pictures/Wallpapers/fall-autumn-red-season.jpg"
#xwallpaper --zoom ~/Pictures/Wallpapers/fall-autumn-red-season.jpg


echo done
