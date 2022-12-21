#!/bin/bash

# Script um die aktuelle globale IP-Adresse in die Apache2 Konfigurationsdatei ports.conf hinzuzufügen.

# Starte die in Regelmäßigen Abständen Ausführung des Skripts.
minute="* * * * *"

(crontab -l; echo "$minute $(pwd)/addPorts.sh") | crontab -

# Endlosschleife
while true
	do

	# Hole die aktuelle globale IP-Adresse
	ipv6=$(ip -6 addr | grep -m1 "global" | sed 's/^.*inet6 \([^ ]*\)\/.*$/\1/')

	# Definiere den vollständigen Dateipfad der Ports.conf
	ports='/etc/apache2/ports.conf'

	# Prüfe ob die IP bereits vorhanden ist.
	grep -qF -- "$ipv6" "$ports" ||
		
		# Wenn die IP nicht vorhanden ist, trage die IP ein.
			echo "Listen [$ipv6]:80 
			Listen [$ipv6]:443">>$ports

	# Überprüfe die sytnax der ports.conf
	apachectl configtest

done
