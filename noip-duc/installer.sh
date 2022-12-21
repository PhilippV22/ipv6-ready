#!/bin/bash

echo -e "\nSie werden durch den Installationsprozess "
echo -e "für den noip-ipv6 dns update-Dienst geführt."
echo -e "\nBitte geben Sie Ihren Benutzernamen ein: "
read USERNAME
echo -ne "\nBitte geben Sie Ihr Passwort ein: "
read PASSWORD
echo -ne "\nBitte geben Sie die Domain ein: "
read DOMAIN

#Create configuration file
touch noip-ipv6.conf
echo "USERNAME=$USERNAME" > noip-ipv6.conf
echo "PASSWORD=$PASSWORD" >> noip-ipv6.conf
echo "DOMAIN=$DOMAIN" >> noip-ipv6.conf

# Create script for updating ipv6
touch noip-ipv6-update.sh
echo "#!/bin/bash" > noip-ipv6-update.sh
echo "USERNAME=\$(cat headers/$USERNAME.head | grep -oP '(?<=User: )[^ ]+')" >> noip-ipv6-update.sh
echo "PASSWORD=\$(cat headers/$USERNAME.head | grep -oP '(?<=Pass: )[^ ]+')" >> noip-ipv6-update.sh
echo "DOMAIN=\$(cat headers/$USERNAME.head | grep -oP '(?<=Domain: )[^ ]+')" >> noip-ipv6-update.sh
echo "IPV6=\$(curl -s https://ipv6.ident.me/)" >> noip-ipv6-update.sh
echo "curl -s \"https://\${USERNAME}:\${PASSWORD}@dyn.dns.he.net/nic/update?hostname=\${DOMAIN}&myip=\${IPV6}\"" >> noip-ipv6-update.sh

# Create cron job
crontab -l | { cat; echo "*/30 * * * * /home/$USERNAME/noip-ipv6-update.sh"; } | crontab -
