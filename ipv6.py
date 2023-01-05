import os
import re
import socket
import sys
import subprocess

# Erfassung des aktuellen Verzeichnisses und des Namens des Skripts
current_directory = os.path.dirname(os.path.realpath(__file__))
script_name = os.path.basename(__file__)
script_path = os.path.join(current_directory, script_name)

# Ermittlung der aktuellen IPv6-Adresse
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.connect(('2001:4860:4860::8888', 80))
ipv6_address = s.getsockname()[0]
s.close()

# Löschen der ports.conf-Datei und Erstellen einer neuen Datei mit den gewünschten Listen-Zeilen
with open('/etc/apache2/ports.conf', 'w') as f:
  f.write('Listen [{}]:80\nListen [{}]:443\n'.format(ipv6_address, ipv6_address))

# Neuladen von Apache
subprocess.run(['systemctl', 'reload', 'apache2'])

# Eintragen des Skripts in den Cron-Tab
subprocess.run(['crontab', '-l'], stdout=subprocess.PIPE)
output = subprocess.run(['grep', '-q', script_path], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
if output.returncode != 0:
  cron_command = '* * * * * {}\n'.format(script_path)
  subprocess.run(['crontab', '-l'], stdout=subprocess.PIPE, input=cron_command.encode())

