import requests

# NO-IP Benutzername und Passwort
username = "EMAIL"
password = "PASSWORD"

# Hostname, den Sie bei NO-IP registriert haben
hostname = "HOSTNAME"

# Die aktuelle globale IPv6-Adresse abrufen
ipv6_address = requests.get("http://ipv6.icanhazip.com").text.strip()

# Die IPv6-Adresse bei NO-IP aktualisieren
response = requests.get(f"http://dynupdate.no-ip.com/nic/update?hostname={hostname}&myip={ipv6_address}", auth=(username, password))

# Überprüfen, ob die Aktualisierung erfolgreich war
if "good" in response.text.lower():
  print("Die IPv6-Adresse wurde erfolgreich aktualisiert.")
else:
  print("Fehler beim Aktualisieren der IPv6-Adresse.")
