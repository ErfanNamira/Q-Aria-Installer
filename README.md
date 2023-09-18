# Q-Aria Installer 🚀
Q-Aria Installer is a Bash script designed to simplify the installation and configuration of essential tools on your Ubuntu Server. With Q-Aria Installer, you can effortlessly set up the following components:

📥 qBittorrent-nox: A lightweight and efficient BitTorrent client.
📂 AriaFileServer: A versatile file server for downloading files with bilt-in autentication.
🌐 Cloudflare Warp: Easily configure and manage proxy settings for your server.

## Installation 📦
```
curl -O https://raw.githubusercontent.com/ErfanNamira/Q-Aria-Installer/main/qAria.sh && chmod +x qAria.sh && sed -i -e 's/\r$//' qAria.sh && sudo apt update && sudo apt install -y dialog && ./qAria.sh
```
## Usage 🚀
Once you've completed the installation, you can start using the installed components:

qBittorrent-nox: Access qBittorrent-nox by navigating to http://your-server-ip:8080 in your web browser.

AriaFileServer: Use AriaFileServer to download your files by visiting http://your-server-ip:2082 in your web browser.

Cloudflare Warp: Please set the proxy server to 127.0.0.1:40000 in qBittorrent Web UI by following Options->Connection->Proxy Server->Type: SOCKS5.
```
bash <(curl -fsSL git.io/warp.sh) status
```
## Uninstallation 🗑️
Select Uninstall qBittorrent-nox from the main menu or Uninstall HTTP Version from submenu of Install/Uninstall AriaFileServer to uninstall qBittorrent-nox/AriaFileServer.
```
curl -O https://raw.githubusercontent.com/ErfanNamira/Q-Aria-Installer/main/qAria.sh && chmod +x qAria.sh && sed -i -e 's/\r$//' qAria.sh && sudo apt update && sudo apt install -y dialog && ./qAria.sh
```
Uninstall WARP
```
bash <(curl -fsSL git.io/warp.sh) uninstall
```
###
Thank you for using Q-Aria Installer! We hope it simplifies your server setup and management. If you encounter any issues or have suggestions for improvement, please don't hesitate to open an issue or contribute to the project. Happy installing! 😊🚀
### Buy Me a Coffee ☕❤️
```
Tron USDT (TRC20): TMrJHiTnE6wMqHarp2SxVEmJfKXBoTSnZ4
LiteCoin (LTC): ltc1qwhd8jpwumg5uywgv028h3lnsck8mjxhxnp4rja
BTC: bc1q2tjjyg60hhsuyauha6uptgrwm32sarhmjlwvae
```


