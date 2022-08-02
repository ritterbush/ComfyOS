#!/bin/sh

# Debian Linux-based (e.g. Mint, Ubuntu, DEBIAN!) setup of ComfyOS.
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

username=gnuslashdebianlinux
password=password
season_wallpaper_name=summer-sand-season.jpg

while [ -n "$1" ]; do
    case "$1" in
        --username|-u)
            if [ -n "$2" ]
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
            if [ -n "$2" ]
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

# Check apt is installed
command -v apt > /dev/null 2>&1 || { echo "ERROR: this script is for Debian-based systems. Apt is required."; exit; }

if [ "$username" != "$USER" ] # -c option is not used, or current user is given
then
# Create new user with given password and add user to wheel, audio, and video groups
sudo useradd -m -G sudo,audio,optical,disk,storage,video "$username" ||
{ echo "Useradd failed. See 'man useradd', and section CAVEATS for allowed usernames."; exit 1; }
(echo "$password"; echo "$password") | sudo passwd "$username"
sudo chmod 733 /home/"$username"
fi # end of -c option is not used

cat > /home/"${username}"/new-user-setup.sh <<EOF
(echo "$password"; echo; echo; echo) | sudo -S apt install xorg xinit zsh git ripgrep fd-find firefox feh sxiv imagemagick fonts-linuxlibertine neofetch htop mpd ncmpcpp libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson libxext-dev asciidoc cmake python3 python3-pip ninja-build libxinerama-dev

# Removed from above: suckless-tools libxft2-dev libpcre3 pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev

# Install Alacritty and Neovim by adding their PPA repositories
# ppa outdated, use below(echo "$password") | sudo -S add-apt-repository ppa:mmstick76/alacritty -y
(echo "$password") | sudo -S add-apt-repository ppa:aslatter/ppa -y
(echo "$password") | sudo -S add-apt-repository ppa:neovim-ppa/unstable -y
(echo "$password") | sudo -S apt update
(echo "$password") | sudo -S apt install alacritty
(echo "$password") | sudo -S apt install neovim

# Install Neovim Packer Plugin Manager
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Directory for programs not from repos
mkdir -p ~/Programs

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
/home/${username}/.local/bin/wal -i ~/Pictures/Wallpapers/"$season_wallpaper_name"
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

# vimrc
cp ~/Programs/files/.vimrc ~/.vimrc

# picom compositor config
mkdir -p ~/.config/picom
cp /etc/xdg/picom.conf.example ~/.config/picom/picom.conf

# Setup colors and opacity, and these also build and install dwm and dmenu
# Run again with different numbers to change

# Alacritty and DWM opacity
~/.local/bin/alacritty-opacity.sh 70
sed -i "s/static const unsigned int baralpha = .*/static const unsigned int baralpha = 0xb2;/" ~/Programs/dwm/config.def.h

# dmenu colors
# Unfortunately, a highlight patch requires manually editing dmenu's wal cache file
sed -i '4 a\
	[SchemeSelHighlight] = { leftHlColor, color1 },' \
$HOME/.cache/wal/colors-wal-dmenu.h
sed -i '5 a\
	[SchemeNormHighlight] = { leftHlColor, color2 },' \
$HOME/.cache/wal/colors-wal-dmenu.h
sed -i '7 a\
	[SchemeNormHighlight] = { leftHlColor, color3 },' \
$HOME/.cache/wal/colors-wal-dmenu.h
leftHlColor=\"$(sed -n 7p $HOME/.cache/wal/colors)\"
color1=\"$(sed -n 10p $HOME/.cache/wal/colors)\"
color2=\"$(sed -n 1p $HOME/.cache/wal/colors)\"
color3=\"$(sed -n 3p $HOME/.cache/wal/colors)\"
sed -i "s/leftHlColor/$leftHlColor/g" $HOME/.cache/wal/colors-wal-dmenu.h
sed -i "s/color1/$color1/" $HOME/.cache/wal/colors-wal-dmenu.h
sed -i "s/color2/$color2/" $HOME/.cache/wal/colors-wal-dmenu.h
sed -i "s/color3/$color3/" $HOME/.cache/wal/colors-wal-dmenu.h

# install dwm and dmenu
cd /home/"$username"/Programs/dwm/ && sudo -S make clean install
cd /home/"$username"/Programs/dmenu/ && sudo -S make clean install
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
(echo "$password") | sudo -S su - "$username" -c "sh /home/${username}/new-user-setup.sh"

# Replace password from script with PASSWORD12345
(echo "$password") | sudo -S sed -i "s/${password}/PASSWORD12345/g" /home/"$username"/new-user-setup.sh

echo "$0 Completed Successfully"
