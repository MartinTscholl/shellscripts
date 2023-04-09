#!/bin/bash

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Icons
# ✔ ✘ ℹ ⚠ ⚡ ⚙ ❓ ❗

display_usage() {
    echo -e "${BLUE}ℹ${NC} Usage: gitctl [command] [...]"
    echo -e "${BLUE}ℹ${NC} Commands:"
    echo -e "${BLUE}ℹ${NC}   update: Updates the git repository with the latest changes"
    echo -e "${BLUE}ℹ${NC}      dotfiles: Updates the dotfiles repository"
}

update_dotfiles() {
    # set the destination directory
    dest_dir="/home/$USER/git/repos/dotfiles/"

    # set the array of source directories and files to copy
    src_files=(
        "/home/$USER/.bashrc"
	"/home/$USER/.xinitrc"
	"/home/$USER/.Xresources"
	"/home/$USER/.config/dunst/"
        "/home/$USER/.config/fish/"
        "/home/$USER/.config/i3/"
	"/home/$USER/.config/kitty/"
	"/home/$USER/.config/picom/"
	"/home/$USER/.config/polybar/"
	"/home/$USER/.config/rofi/"
	"/home/$USER/.config/wallpapers/"
    )

    # loop through the source files and directories, and copy them to the destination
    for file in "${src_files[@]}"
    do
        cp -R "$file" "$dest_dir"
    done

    # change directory to the destination
    cd "$dest_dir"

    # add the files to git and commit with message "update"
    git add .
    git commit -m "update"

    # push to the default remote branch
    git push

    # change directory back to the original
    cd -
}

case "$1" in
    update)
        case "$2" in
            dotfiles)
                update_dotfiles
                ;;
            *)
		display_usage
		;;
        esac
        ;;
    *)
        display_usage
        ;;
esac

