#!/bin/bash

# Prüfe, ob Apache2 und curl bereits installiert sind
if ! [ -x "$(command -v apache2)" ] || ! [ -x "$(command -v curl)" ]; then
  # Installiere Apache2 und curl
  apt-get update
  apt-get install apache2 curl php -y
fi

# Prüfe, ob die Konfigurationsdatei bereits existiert
if [ ! -f "/root/no-ip2.conf" ]; then
  # Frage Benutzername und Passwort ab
  echo "Bitte geben Sie Ihren No-IP-Benutzernamen ein:"
  read USERNAME
  echo "Bitte geben Sie Ihr No-IP-Passwort ein:"
  read -s PASSWORD
  echo "Bitte geben Sie Ihre No-IP-Host-Domain ein:"
  read HOSTNAME

  # Konfiguriere No-IP DUC
  echo "$USERNAME $PASSWORD" > /root/no-ip2.conf
  echo "$HOSTNAME" >> /root/no-ip2.conf
else
  # Lese Benutzername und Passwort aus der Konfigurationsdatei
  USERNAME=$(head -n 1 /root/no-ip2.conf)
  PASSWORD=$(tail -n 1 /root/no-ip2.conf)
  HOSTNAME=$(tail -n 2 /root/no-ip2.conf | head -n 1)
fi

# Trage das Update-Skript im Crontab ein, um die IPv6-Adresse jede Minute zu aktualisieren
echo "* * * * * /root/ipv6-ready/duc.py" | crontab -

# Aktualisiere die IPv6-Adresse
function update_ipv6 {
  # Abfrage der aktuellen IPv6-Adresse
  ipv6_address=$(ip -6 addr show dev eth0 scope global | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')

  # Löschen aller "Listen"-Zeilen in der Konfigurationsdatei von Apache2
  sed -i "/^Listen/d" /etc/apache2/ports.conf

  # Hinzufügen der neuen "Listen"-Zeile in der Konfigurationsdatei von Apache2
  echo "Listen [${ipv6_address}]:443" >> /etc/apache2/ports.conf
  echo "Listen [${ipv6_address}]:80" >> /etc/apache2/ports.conf

  # Neustarten von Apache2
  systemctl restart apache2
}

update_ipv6

# Trage den DUC im Crontab ein, um ihn jede Minute auszuführen
echo "* * * * * /root/ipv6-ready/ipv6.sh" | crontab -
