#!/bin/bash

# Q-Aria Installer
# ErfanNamira
# https://github.com/ErfanNamira/Q-Aria-Installer

# Function to display a completion message in a dialog box
completion_message_dialog() {
    local server_ip="$1"
    local webui_port="$2"
    dialog --backtitle "Q-Aria Installer" --title "Installation Complete" --msgbox "qBittorrent-nox setup has completed. You can now access it at http://$server_ip:$webui_port." 12 60
}

# Function to create a directory if it doesn't exist
create_directory() {
    local directory="$1"
    if [ ! -d "$directory" ]; then
        mkdir -p "$directory"
    fi
}

# Function to install qBittorrent-nox
install_qbittorrent_nox() {
    # Step 1: Ask the user if they want to proceed
    dialog --backtitle "Q-Aria Installer" --title "Install qBittorrent-nox" --yesno "Do you want to install qBittorrent-nox?" 10 50
    response=$?
    if [ $response -ne 0 ]; then
        return
    fi

    # Step 2: Ask for the webui-port
    webui_port=$(dialog --inputbox "Enter the webui port for qBittorrent-nox:" 10 50 8080 2>&1 >/dev/tty)

    # Step 3: Add qBittorrent repository and install qBittorrent-nox
    sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
    sudo apt update
    sudo apt install -y qbittorrent-nox

    # Step 4: Create the qbittorrent-nox service file with the specified webui-port
    service_file="/etc/systemd/system/qbittorrent-nox.service"
    cat <<EOL | sudo tee "$service_file"
[Unit]
Description=qBittorrent-nox
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=$webui_port
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

    # Step 5: Start qBittorrent-nox service
    sudo systemctl daemon-reload
    sudo systemctl enable qbittorrent-nox
    sudo systemctl start qbittorrent-nox
    sudo systemctl status qbittorrent-nox

    # Step 6: Add users and group
    sudo adduser --system --group qbittorrent-nox
    sudo adduser root qbittorrent-nox

    # Step 8: Display completion message in a dialog box
    server_ip=$(hostname -I | awk '{print $1}')
    completion_message_dialog "$server_ip" "$webui_port"

    # Step 9: Optionally, run qBittorrent-nox
    dialog --yesno "Do you want to run qBittorrent-nox now?" 10 50
    response=$?
    if [ $response -eq 0 ]; then
        qbittorrent-nox
    fi
}

# Function to install and configure AriaFileServer
install_ariafileserver() {
    while true; do
        # Display the AriaFileServer submenu using dialog
        choice=$(dialog --menu "AriaFileServer Installation Menu" 15 50 4 \
            1 "Install HTTP Version" \
            2 "Uninstall HTTP Version" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                # Install HTTP version of AriaFileServer
                install_ariafileserver_http
                ;;
            2)
                # Uninstall HTTP version of AriaFileServer
                uninstall_ariafileserver_http
                ;;
            *)
                # Return to the main menu if the user cancels
                return
                ;;
        esac
    done
}

# Function to install HTTP version of AriaFileServer
install_ariafileserver_http() {
    # Step 1: Ask the user for the location of the Downloads folder
    downloads_folder=$(dialog --inputbox "Enter the location of the Downloads folder (default: /home/qbittorrent-nox/Downloads):" 10 50 "/home/qbittorrent-nox/Downloads" 2>&1 >/dev/tty)
    downloads_folder="${downloads_folder:-/home/qbittorrent-nox/Downloads}"

    # Create the Downloads folder if it doesn't exist
    create_directory "$downloads_folder"

    # Step 2: Ask the user to enter the username for AriaFileServer
    username=$(dialog --inputbox "Enter the username for AriaFileServer:" 10 50 2>&1 >/dev/tty)

    # Step 3: Ask the user to enter the password for AriaFileServer
    password=$(dialog --passwordbox "Enter the password for AriaFileServer:" 10 50 2>&1 >/dev/tty)

    # Generate SHA-256 hash using hashlib
    hashed_password=$(python3 -c "import hashlib; print(hashlib.sha256('$password'.encode('utf-8')).hexdigest())")

    # Step 4: Ask the user for the port that AriaFileServer will run on
    ariafileserver_port=$(dialog --inputbox "Enter the port for AriaFileServer (e.g., 2082):" 10 50 2082 2>&1 >/dev/tty)

    # Step 5: Download AriaFileServerHTTP.py and save it in the specified (or default) location
    ariafileserver_url="https://raw.githubusercontent.com/ErfanNamira/AriaFileServer/main/AriaFileServerHTTP.py"
    ariafileserver_path="$downloads_folder/AriaFileServerHTTP.py"

    # Download AriaFileServerHTTP.py
    if ! wget -O "$ariafileserver_path" "$ariafileserver_url"; then
        dialog --msgbox "Failed to download AriaFileServerHTTP.py. Please check your internet connection and try again." 10 60
        return
    fi

    # Step 6: Install required packages
    sudo apt install -y python3-pip
    pip3 install flask passlib

    # Step 7: Edit AriaFileServerHTTP.py to set the username, hashed password, and port
    sed -i "s|'aria':.*|'$username': '$hashed_password',|" "$ariafileserver_path"
    sed -i "s/port=2082/port=$ariafileserver_port/" "$ariafileserver_path"

    # Step 8: Create systemd service for AriaFileServer HTTP version
    service_file="/etc/systemd/system/ariafileserverhttp.service"
    cat <<EOL | sudo tee "$service_file"
[Unit]
Description=AriaFileServer HTTP Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 $ariafileserver_path
WorkingDirectory=$downloads_folder
Restart=always
User=root
Environment=PATH=/usr/bin:/usr/local/bin
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

    # Step 9: Start and enable AriaFileServer HTTP service
    sudo systemctl daemon-reload
    sudo systemctl enable ariafileserverhttp
    sudo systemctl start ariafileserverhttp

    # Step 10: Get server IP
    server_ip=$(hostname -I | awk '{print $1}')

    # Step 11: Display completion message
    dialog --msgbox "AriaFileServer HTTP version has been installed successfully. You can access it at http://$server_ip:$ariafileserver_port" 12 60
}

# Function to install and configure WARP Proxy
install_warp_proxy() {
    # Step 1: Install WARP Proxy
    bash <(curl -fsSL git.io/warp.sh) proxy

    # Step 2: Display completion message in a dialog box
    dialog --msgbox "Cloudflare WARP has been set up successfully. Please set the proxy server to 127.0.0.1:40000 in qBittorrent Web UI by following Options->Connection->Proxy Server->Type: SOCKS5." 12 80
}

# Function to uninstall HTTP version of AriaFileServer
uninstall_ariafileserver_http() {
    # Stop and disable AriaFileServer HTTP service
    sudo systemctl stop ariafileserverhttp
    sudo systemctl disable ariafileserverhttp

    # Remove AriaFileServer HTTP service file
    sudo rm -f /etc/systemd/system/ariafileserverhttp.service

    # Remove AriaFileServer script file
    sudo rm -f "$ariafileserver_path_http"

    # Display completion message
    dialog --msgbox "AriaFileServer HTTP version has been uninstalled successfully." 10 60
}

# Function to change qBittorrent-nox WebUI Port
change_webui_port() {
    # Step 1: Ask the user for the new webui port
    new_webui_port=$(dialog --inputbox "Enter the new WebUI port for qBittorrent-nox:" 10 50 8080 2>&1 >/dev/tty)

    # Step 2: Update the qbittorrent-nox service file with the new port
    service_file="/etc/systemd/system/qbittorrent-nox.service"
    sudo sed -E -i "s/(--webui-port=)[0-9]+/\1$new_webui_port/" "$service_file"

    # Step 3: Reload the qbittorrent-nox service
    sudo systemctl daemon-reload
    sudo systemctl restart qbittorrent-nox

    # Step 4: Display completion message in a dialog box
    dialog --msgbox "qBittorrent-nox setup has completed. You can now access it at http://$server_ip:$new_webui_port." 12 60
}

# Function to uninstall qBittorrent-nox
uninstall_qbittorrent_nox() {
    # Step 1: Ask the user if they want to uninstall qBittorrent-nox
    dialog --yesno "Do you want to uninstall qBittorrent-nox? This will remove qBittorrent-nox and all related files." 10 50
    response=$?
    if [ $response -ne 0 ]; then
        return
    fi

    # Step 2: Remove qBittorrent-nox package and related files
    sudo apt remove -y qbittorrent-nox
    sudo apt -y autoremove
    sudo deluser root qbittorrent-nox
    sudo deluser qbittorrent-nox
    sudo rm -r /opt/qbittorrent

    # Step 3: Remove qBittorrent-nox service file
    sudo rm -f /etc/systemd/system/qbittorrent-nox.service

    # Step 4: Remove additional qBittorrent configuration folders
    sudo rm -rf /root/.config/qBittorrent
    sudo rm -rf /root/.cache/qBittorrent
    sudo rm -rf /root/.local/share/qBittorrent
    sudo rm -rf ~/.config/qBittorrent

    # Step 5: Display uninstallation complete message
    dialog --msgbox "qBittorrent-nox has been uninstalled successfully." 10 50
}

# Main menu loop
while true; do
    # Display the main menu using dialog
    choice=$(dialog --backtitle "Q-Aria Installer" --title "Main Menu" --menu "Choose an option:" 15 50 7 \
        1 "Install qBittorrent-nox" \
        2 "Uninstall qBittorrent-nox" \
        3 "Change qBittorrent-nox WebUI Port" \
        4 "Install/Uninstall AriaFileServer" \
        5 "Install WARP Proxy" \
        6 "Exit" \
        2>&1 >/dev/tty)

    # Check the user's choice and take appropriate actions
    case $choice in
        1)
            install_qbittorrent_nox
            ;;
        2)
            uninstall_qbittorrent_nox
            ;;
        3)
            change_webui_port
            ;;
        4)
            install_ariafileserver
            ;;
        5)
            install_warp_proxy
            ;;
        6)
            # Exit the script
            exit 0
            ;;
        *)
            # Handle invalid choices
            dialog --msgbox "Invalid option. Please select a valid option." 10 40
            ;;
    esac
done
