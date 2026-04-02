#!/bin/bash

sudo -v

force_installation=0
install_packages=1
positional_args=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            force_installation=1
            shift # past argument
            ;;
        -s|--skip-packages)
            install_packages=0
            shift # past argument
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            positional_args+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

set -- "${positional_args[@]}" # restore positional parameters


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PACKAGES_PATH=$SCRIPT_DIR/packages.txt
PACKAGES_AUR_PATH=$SCRIPT_DIR/packages-aur.txt

declare -A ignore=(
    [.git]=1
    [README.md]=1
    [requirements.txt]=1
    [install.sh]=1
    [packages.txt]=1
    [packages-aur.txt]=1
    [bin]=1
    [polkit]=1
)

if [ "$install_packages" -eq 1 ]; then
    sudo pacman -S --noconfirm base-devel

    if which yay > /dev/null; then
        echo "Skipping yay installation because it's already installed."
    else
        echo "Installing yay"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
    fi

    sudo pacman -S --noconfirm - < $PACKAGES_PATH
    sudo yay -S --noconfirm - < $PACKAGES_AUR_PATH
fi

function link_files {
    local current_dir=$1
    local force_linking=$2
    local should_use_ignore_list=${3:-1}
    local directory_prefix=${4:-""}

    local home_dir=$(echo ~)
    local destination="$home_dir/$directory_prefix$current_dir"

    local files_in_dir=$(ls -A $current_dir)

    for file_in_dir in $files_in_dir; do
        if [[ $should_use_ignore_list -eq 1 && -n "${ignore[$file_in_dir]}" ]]; then
            echo "Ignoring: $file_in_dir"
            continue
        fi

        if [[ -n $file_in_dir && -d $current_dir$file_in_dir ]]; then
            directory_to_create=$destination$file_in_dir
            mkdir -p -v $directory_to_create
            link_files "$current_dir$file_in_dir/" $force_linking $should_use_ignore_list $directory_prefix
        else
            if [[ $force_linking = 1 ]]; then
                echo "Removing: $destination$file_in_dir"
                rm -f $destination$file_in_dir
            fi

            file=$(realpath $current_dir$file_in_dir)

            if [ -f $destination$file_in_dir ]; then
                echo "File: $destination$file_in_dir already exists. Skipping"
            else
                echo "Linking $file with $destination$file_in_dir"
                ln -s $file $destination$file_in_dir
            fi
        fi
    done
}

link_files "" $force_installation 1
link_files "bin/" $force_installation 0 ".local/"

if [ ! -f ~/.vim/autoload/plug.vim ]; then
    echo "Downloading Plug"
    mkdir -p ~/.vim/autoload
    wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ~/.vim/autoload/plug.vim
    echo "Installing nvim plugins with Plug"
    nvim +'PlugInstall --sync' +qa
fi

function add_current_user_to_group {
    group_name=$1
    current_user=$(whoami)

    if groups | grep -q "\\b$group_name\\b"; then
        echo "User '$current_user' is already a member of group '$group_name'. Skipping"
    else
        # Adding current user to input group so that keyboard-state module in waybar works
        # https://github.com/Alexays/Waybar/wiki/Module:-Keyboard-State
        sudo usermod -a -G $group_name $current_user
        echo "Added '$current_user' to '$group_name' group. Restart system to apply changes"
    fi
}

add_current_user_to_group "input"

# Group storage is used to manage plugged in USB drives without sudo password
add_current_user_to_group "storage"
mkdir -p $HOME/.config/quickshell-usb
sudo cp polkit/10-usb-mount.rules /etc/polkit-1/rules.d/10-usb-mount.rules

function enable_system_service {
    local service_name=$1

    local is_service_active=$(systemctl is-active --quiet $service_name)

    if [[ $is_service_active -eq 0 ]]; then
        echo "Service $service_name is already running. Skipping"
        return
    fi

    sudo systemctl start $service_name

    local is_service_enabled=$(systemctl is-enabled --quiet $service_name)

    if [[ $is_service_enabled -eq 0 ]]; then
        echo "Service $service_name is already enabled. Skipping"
        return
    fi

    sudo systemctl enable $service_name
}

enable_system_service NetworkManager.service
enable_system_service bluetooth.service

# Configure firewall
ufw_status=$(sudo ufw status)
if echo "$ufw_status" | grep -q "Status: active"; then
    echo "Firewall (ufw) is already active. Skipping"
else
    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    sudo ufw enable
    sudo systemctl enable ufw

    sudo ufw reload

    echo "Firewall (ufw) is configured and enabled"
fi

# Set pcmanfm-qt as default file manager
xdg-mime default pcmanfm-qt.desktop inode/directory

hyprctl reload
