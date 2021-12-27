#!/bin/sh

# Arch Linux-based (e.g. Manjaro, Artix, ARCH!) setup of ComfyOS.
# Run with options -u newusername -p passwordfornewusername, lest the defaults be used.
# Or run with -c  and -p passwordofcurrentuser to use the current user, and possibly overwrite some config files.

command -v pacman || echo "ERROR: this script is for Arch-based systems. Pacman is required."; exit

show_usage(){
    printf "Usage:\n\n  $0 [options [parameters]]\n"
    printf "\n"
    printf "Defaults when used without options:\n"
    printf "\n"
    printf "  Username: gnuslasharchlinux\n"
    printf "  Password: password\n"
    printf "\n"
    printf "Options [parameters]:\n"
    printf "\n"
    printf "  -u|--username [username]   Specify username; if special characters are\n                       used use quotes.\n"
    printf "  -p|--password [password]   Specify password; if special characters are\n                       used use quotes.\n"
    printf "  -c|--current               Use the current user; must also specify the 
                             current user's password with -p or else the 
                             default password is used.\n"
    printf "  -h|--help                  Print this help.\n"
exit
}

username=gnuslasharchlinux
password=password

while [ -n "$1" ]; do
    case "$1" in
        --username|-u)
            if [ -n "$2"  ]
            then
                username="$2"
                shift 2
            else
                echo "-u flag requires a username"
                exit
            fi
            ;;
        --current|-c)
            username="$USER"
            shift
            ;;
        --help|-h)
            show_usage
            ;;
        --password|-p)
            if [ -n "$2"  ]
            then
                password="$2"
                shift 2
            else
                echo "-p option requires a password"
                exit
            fi
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            ;;
    esac
done

if [ $username != ${USER} ] # -c option is not used, or current user is given
then
# Create new user with given password and add user to wheel, audio, and video groups
sudo useradd -m -G wheel,audio,video "$username" ||
echo "Useradd failed. See 'man useradd', and section CAVEATS for allowed usernames."; exit 1
(echo "$password"; echo "$password") | sudo passwd "$username"
sudo chmod 733 /home/"$username"
fi # end of -c option is not used

cat > /home/${username}/new-user-setup.sh <<End-of-message
(echo "$password"; echo; echo; echo) | sudo -S pacman -S xorg xorg-xinit zsh exa git alacritty neovim firefox picom feh sxiv ttf-linux-libertine python-pywal neofetch htop mpd ncmpcpp

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
wal -i ~/Pictures/Wallpapers/winter-snow-season.jpg
sleep 3

# Directory for building programs from source
mkdir -p ~/Programs/files

# Get my dwm/dmenu desktop environment, various dotfiles, and scripts
git clone https://github.com/ritterbush/files ~/Programs/files/

# Put dwm and dmenu in a good spot
mv ~/Programs/files/dwm ~/Programs/
mv ~/Programs/files/dmenu ~/Programs/

# Copy start file for login managers
echo "$password" | sudo -S cp ~/Programs/files/dwm.desktop /usr/share/xsessions/dwm.desktop

# xinitrc
cp ~/Programs/files/.xinitrc ~/.xinitrc
# link it to .xsession
ln -s ~/.xinitrc ~/.xsession

# zshrc
cp ~/Programs/files/.zshrc ~/.zshrc

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

echo done
