# ComfyOS
### Seasonal Comfort OS

![/comfy/](/ComfyOS.png)
![/comfy/](/ComfyOSWinter.png)
![/comfy/](/ComfyOSSpring.png)
![/comfy/](/ComfyOSSummer.png)



Okay, it's not really an OS, since it assumes you already have an Arch or Debian-based distro installed.
But it is the look, feel, and functionality of the OS for the user. See below to see what it uses.

### First curl/wget/download the correct script, be it Arch or Debian-based, and then
### Run it with the options -u [username] and -p [password] to make a new user username and password to try it out.
### OR, run it with the options -c and -p [current user password] to use the current user and use CAUTION, 
### because certain files, such as .zshrc, .xinitrc, and some other config files will get overwritten!

#### This script installs and makes use of:

the DWM window manager, along with Dmenu (with patches and modifications);
the Alacritty terminal emulator;
the MPD music server and ncmpcpp music player;
Py-Wal generated colorschemes;
and various scripts to make use of all of these together.

#### Script commands:
op [number] # Changes opacity of alacritty and menu bar (Ctrl + Shift + Q to restart DWM so changes take effect)

img [directory] # View images in directory, press Enter to view all images, and m to select one, q to quit and see that image become your new wallpaper and colorscheme

wp [file] # Similar to img, but you select a specific image file to become your new wallpaper + colorscheme

music # Opens ncmpcpp music player


Note that DWM, Dmenu, and ncmpcpp are using default keybindings, so lookup those programs to see how they work in detail.

#### Overview of key bindings:

Alt + Shift + Enter # Open terminal.

Alt + [number] # Switch to the [number] tag/workspace.

Alt + p # Bring up Dmenu, and type to bring up program, Enter to open highlighed program; or Esc to exit Dmenu without opening any program.

Alt + Shift + [number] # Move active window to the [number] tag/workspace.

Alt + Enter # The focused window trades places with the more prominent window or vice versa of a single tag/workspace.
