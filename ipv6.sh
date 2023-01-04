#!/bin/bash

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

apt install curl apache2 php -y

# Erstelle einen DUC für No-IP
cat > /root/update_ip.sh << EOF
#!/bin/bash

# Hole die aktuelle IPv6-Adresse
IP=$(curl -s http://ipv6.icanhazip.com)

# Aktualisiere die No-IP-Host-Domain mit der aktuellen IPv6-Adresse
curl "http://dynupdate.no-ip.com/nic/update?hostname=$HOSTNAME&myip=$IP" -u "$USERNAME:$PASSWORD"
EOF

# Setze die Berechtigungen für das Update-Skript
chmod +x /root/update_ip.sh

# Trage das Update-Skript im Crontab ein, um die IPv6-Adresse jede Minute zu aktualisieren
echo "* * * * * /root/update_ip.sh" | crontab -

# Aktualisiere die IPv6-Adresse
function update_ipv6 {
  # Ermittle die aktuelle IPv6-Adresse
  IPV6=$(curl -s http://ipv6.icanhazip.com)

  # Aktualisiere die Konfigurationsdatei von Apache2 mit der neuen IPv6-Adresse
  sed -i "s/Listen.*/Listen [$IPV6]:80/g" /etc/apache2/ports.conf

  # Lade Apache2 neu
  service apache2 reload
}

update_ipv6
