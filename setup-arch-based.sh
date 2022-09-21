#!/bin/sh

# Arch Linux-based (e.g. Manjaro, Artix, ARCH!) setup of ComfyOS.
# Run with options -u newusername -p passwordfornewusername, lest the defaults be used.
# Or run with -c  and -p passwordofcurrentuser to use the current user, and possibly overwrite some config files.

show_usage(){
    printf "Usage:\n\n  %s [options [parameters]]\n" "$0"
    printf "\n"
    printf "Defaults when used without options:\n"
    printf "\n"
    printf "  Username: gnuslasharchlinux\n"
    printf "  Password: password\n"
    printf "\n"
    printf "Options [parameters]:\n"
    printf "\n"
    printf "  -u|--username [username]   Specify username; if special characters are
                             used use single quotes.\n"
    printf "  -p|--password [password]   Specify password; if special characters are
                             used use single quotes.\n"
    printf "  -c|--current               Use the current user; must also specify the
                             current user's password with -p or else the
                             default password is used.\n"
    printf "  -h|--help                  Print this help.\n"
exit
}

if [ $# -eq 0 ]; then
    show_usage
fi

username=gnuslasharchlinux
password=password
season_wallpaper_name=fall-autumn-red-season.jpg

while [ -n "$1" ]; do
    case "$1" in
        --username|-u)
            if [ -n "$2" ]
            then
                username="$2"
                shift 2
            else
                echo "-u flag requires a username"
                exit 1
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
            if [ -n "$2" ]
            then
                password="$2"
                shift 2
            else
                echo "-p option requires a password"
                exit 1
            fi
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            ;;
    esac
done

# Check pacman is installed
command -v pacman > /dev/null 2>&1 || { echo "ERROR: this script is for Arch-based systems. Pacman is required."; exit; }

if [ "$username" != "$USER" ] # -c option is not used, or current user is given
then
# Create new user with given password and add user to wheel, audio, and video groups
sudo useradd -m -G wheel,audio,optical,disk,storage,video "$username" ||
{ echo "Useradd failed. See 'man useradd', and section CAVEATS for allowed usernames."; exit 1; }
(echo "$password"; echo "$password") | sudo passwd "$username"
sudo chmod 733 /home/"$username"
fi # end of -c option is not used

cat > /home/"${username}"/new-user-setup.sh <<"EOF"
(echo "$1"; echo; echo; echo; echo) | sudo -S pacman -S xorg xorg-xinit pipwire pipewire-alsa pipewire-pulse zsh exa git alacritty neovim ripgrep fd firefox picom feh sxiv ttf-linux-libertine python-pywal neofetch htop mpv mpd ncmpcpp

# Install Neovim Packer Plugin Manager
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 "$HOME"/.local/share/nvim/site/pack/packer/start/packer.nvim

# Download Fall wallpaper from Pexels under CC0 license
mkdir -p "$HOME"/Pictures/Wallpapers
#fall
curl https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg > "$HOME"/Pictures/Wallpapers/fall-autumn-red-season.jpg
#winter
curl https://images.pexels.com/photos/688660/pexels-photo-688660.jpeg > "$HOME"/Pictures/Wallpapers/winter-snow-season.jpg
#spring
curl https://images.pexels.com/photos/570041/pexels-photo-570041.jpeg > "$HOME"/Pictures/Wallpapers/spring-flower-season.jpg
#summer
curl https://images.pexels.com/photos/7084186/pexels-photo-7084186.jpeg > "$HOME"/Pictures/Wallpapers/summer-sand-season.jpg

# Generate py-wal cache files before building dwm and dmenu
wal -i "$HOME"/Pictures/Wallpapers/"$2"
sleep 3

# Directory for building programs from source
mkdir -p "$HOME"/Programs/files

# Get my dwm/dmenu desktop environment, various dotfiles, and scripts
git clone https://github.com/ritterbush/files "$HOME"/Programs/files/

# Put dwm and dmenu in a good spot
mv "$HOME"/Programs/files/dwm "$HOME"/Programs/
mv "$HOME"/Programs/files/dmenu "$HOME"/Programs/

# Copy start file for login managers
echo "$1" | sudo -S cp "$HOME"/Programs/files/dwm.desktop /usr/share/xsessions/dwm.desktop

# xinitrc
cp "$HOME"/Programs/files/.xinitrc "$HOME"/.xinitrc
# link it to .xsession
ln -s "$HOME"/.xinitrc "$HOME"/.xsession

# zshrc
cp "$HOME"/Programs/files/.zshrc "$HOME"/.zshrc

# change shell to zsh
(echo "$1"; echo /bin/zsh) | chsh

# shell scripts, neovim config and plugins, alacritty config
cp -r "$HOME"/Programs/files/.local "$HOME"/
cp -r "$HOME"/Programs/files/.config "$HOME"/

# vimrc
cp "$HOME"/Programs/files/.vimrc "$HOME"/.vimrc

# picom compositor config
mkdir -p "$HOME"/.config/picom
cp /etc/xdg/picom.conf.example "$HOME"/.config/picom/picom.conf

# Setup colors and opacity, and these also build and install dwm and dmenu
# Run again with different numbers to change

# Alacritty and DWM opacity
"$HOME"/.local/bin/alacritty-opacity.sh 70
sed -i "s/static const unsigned int baralpha = .*/static const unsigned int baralpha = 0xb2;/" "$HOME"/Programs/dwm/config.def.h

# dmenu colors
# Unfortunately, a highlight patch requires manually editing dmenu's wal cache file
sed -i '4 a\
	[SchemeSelHighlight] = { leftHlColor, color1 },' \
"$HOME"/.cache/wal/colors-wal-dmenu.h
sed -i '5 a\
	[SchemeNormHighlight] = { leftHlColor, color2 },' \
"$HOME"/.cache/wal/colors-wal-dmenu.h
sed -i '7 a\
	[SchemeNormHighlight] = { leftHlColor, color3 },' \
"$HOME"/.cache/wal/colors-wal-dmenu.h
leftHlColor=\"$(sed -n 7p "$HOME"/.cache/wal/colors)\"
color1=\"$(sed -n 10p "$HOME"/.cache/wal/colors)\"
color2=\"$(sed -n 1p "$HOME"/.cache/wal/colors)\"
color3=\"$(sed -n 3p "$HOME"/.cache/wal/colors)\"
sed -i "s/leftHlColor/$leftHlColor/g" "$HOME"/.cache/wal/colors-wal-dmenu.h
sed -i "s/color1/$color1/" "$HOME"/.cache/wal/colors-wal-dmenu.h
sed -i "s/color2/$color2/" "$HOME"/.cache/wal/colors-wal-dmenu.h
sed -i "s/color3/$color3/" "$HOME"/.cache/wal/colors-wal-dmenu.h

# install dwm and dmenu
cd "$HOME"/Programs/dwm/ && sudo -S make clean install
cd "$HOME"/Programs/dmenu/ && sudo -S make clean install
EOF

# Make that script executable by owner
(echo "$password") | sudo -S chmod 700 /home/"$username"/new-user-setup.sh

#echo "$password" | sudo -S su - "$username" -c "sh /home/"$username"/new-user-setup.sh

if [ "$username" != "$USER" ] # -c option is not used
then
# Change owner to be new user
sudo -S chown "${username}:$username" /home/"$username"/new-user-setup.sh

# Return permissions to new user's home directory
sudo -S chmod 700 /home/"$username"
fi

# Execute script as new or current user
(echo "$password") | sudo -S su - "$username" -c "sh /home/${username}/new-user-setup.sh $password $season_wallpaper_name"

echo "$0 Completed Successfully"
