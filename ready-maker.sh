#!/bin/bash

# Überprüfen, ob das System Ubuntu oder Debian ist
if [ "$(lsb_release -is)" != "Ubuntu" ] && [ "$(lsb_release -is)" != "Debian" ]
then
  # Das Skript wird nicht auf anderen Distributionen unterstützt
  echo "Das Skript wird nur auf Ubuntu oder Debian-Systemen unterstützt."
  exit 1
fi

# Benutzereingabe abfragen, welche Domain bei NoIp aktualisiert werden soll
echo "Bitte geben Sie die Domain ein, die bei NoIp aktualisiert werden soll:"
read domain

# Überprüfen, ob verschlüsselte Noip-Dateien vorhanden sind
if [ ! -f "encrypted_noip_username.txt" ] || [ ! -f "encrypted_noip_password.txt" ]
then
  # Benutzereingabe abfragen und verschlüsselte Noip-Dateien erstellen
  read -p "Bitte geben Sie den Noip-Benutzernamen ein: " noip_username
  read -s -p "Bitte geben Sie das Noip-Passwort ein: " noip_password
  echo $noip_username | openssl enc -e -aes-256-cbc -k secret > encrypted_noip_username.txt
  echo $noip_password | openssl enc -e -aes-256-cbc -k secret > encrypted_noip_password.txt
fi

# Verschlüsseltes Noip-Passwort und Benutzernamen abrufen
encrypted_noip_username=$(cat encrypted_noip_username.txt)
encrypted_noip_password=$(cat encrypted_noip_password.txt)

# Noip-Anmeldeinformationen entschlüsseln und neu verschlüsseln
noip_username=$(echo $encrypted_noip_username | openssl enc -d -aes-256-cbc -k secret)
noip_password=$(echo $encrypted_noip_password | openssl enc -d -aes-256-cbc -k secret)
echo $noip_username | openssl enc -e -aes-256-cbc -k secret > encrypted_noip_username.txt
echo $noip_password | openssl enc -e -aes-256-cbc -k secret > encrypted_noip_password.txt

chmod 777 ipv6-duc.sh
./ipv6-duc.sh

# Benutzereingabe abfragen, ob ein Apache2-Letsencrypt-Zertifikat erstellt werden soll
echo "Möchten Sie ein Apache2-Letsencrypt-Zertifikat erstellen? (j/n)"
read create_cert

# Aktuelle globale IPv6-Adresse abrufen und in der ports.conf eintragen
ipv6=$(curl -s "http://checkip.dyndns.org" | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
sed -i "s/Listen \[::\]:80/Listen [$ipv6]:80/g" /etc/apache2/ports.conf

# Apache2 neu starten
service apache2 restart

if [ "$create_cert" == "j" ]
then
  # Benutzereingabe abfragen und Apache2-Letsencrypt-Zertifikat erstellen
  read -p "Bitte geben Sie die E-Mail-Adresse für das Zertifikat ein: " email
  certbot --apache -m $email -d $domain
fi

# Eine Minute warten, bevor das Skript erneut ausgeführt wird
sleep 60
done


 
