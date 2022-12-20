#!/bin/bash

# Überprüfen, ob das System Ubuntu oder Debian ist
if [ "$(lsb_release -is)" != "Ubuntu" ] && [ "$(lsb_release -is)" != "Debian" ]
then
  # Das Skript wird nicht auf anderen Distributionen unterstützt
  echo "Das Skript wird nur auf Ubuntu oder Debian-Systemen unterstützt."
  exit 1
fi

# Verschlüsseltes Noip-Passwort und Benutzernamen abrufen
encrypted_noip_username=$(cat encrypted_noip_username.txt)
encrypted_noip_password=$(cat encrypted_noip_password.txt)
encrypted_noip_domain=$(cat encrypted_noip_domain.txt)

# Noip-Anmeldeinformationen entschlüsseln
noip_username=$(echo $encrypted_noip_username)
noip_password=$(echo $encrypted_noip_password)
noip_domain=$(echo $encrypted_noip_domain)

# Aktuelle IPv6-Adresse abrufen
ipv6=$(ip -6 addr show dev eth0 scope global | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')

# Noip-API aufrufen, um die IPv6-Adresse der angegebenen Domain zu aktualisieren
curl "https://dynupdate.no-ip.com/nic/update?hostname=$noip_domain&myip=$ipv6" -u "$noip_username:$noip_password"
