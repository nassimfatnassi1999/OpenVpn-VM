# Connexion VPN avec client1.ovpn

Ce guide explique comment se connecter à un serveur OpenVPN en utilisant le fichier `client1.ovpn` sur **Ubuntu** et **Manjaro XFCE**.

---

## Prérequis

- Fichier de configuration VPN : `client1.ovpn`

---

## Installation d’OpenVPN
```bash
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
```

### Ubuntu / Debian :
```bash
sudo apt update
sudo apt install openvpn network-manager-openvpn network-manager-openvpn-gnome
```
### Manjaro / Arch Linux :
```bash
sudo pacman -Syu openvpn networkmanager-openvpn
sudo systemctl restart NetworkManager
```
###  Avec NetworkManager (CLI):
```bash
mkdir -p ~/openvpn-configs
cp client1.ovpn ~/openvpn-configs/
sudo nmcli connection import type openvpn file ~/openvpn-configs/client1.ovpn
nmcli connection up id "client1"   # Remplacer "client1" par le nom exact de la connexion
nmcli connection down id "client1" # Pour se déconnecter
```
### Avec OpenVPN en ligne de commande:
```bash
sudo openvpn --config ~/openvpn-configs/client1.ovpn --daemon
```



