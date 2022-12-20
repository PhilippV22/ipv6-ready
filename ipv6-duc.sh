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

# Noip-Anmeldeinformationen entschlüsseln
noip_username=$(echo $encrypted_noip_username | openssl enc -d -aes-256-cbc -k secret)
noip_password=$(echo $encrypted_noip_password | openssl enc -d -aes-256-cbc -k secret)

# Aktuelle IPv6-Adresse abrufen
ipv6=$(curl -s "http://checkip.dyndns.org" | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')

# Noip-API aufrufen, um die IPv6-Adresse der angegebenen Domain zu aktualisieren
curl "https://dynupdate.no-ip.com/nic/update?hostname=$DOMAIN&myip=$ipv6" -u "$noip_username:$noip_password"
