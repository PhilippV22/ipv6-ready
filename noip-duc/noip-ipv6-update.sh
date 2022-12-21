#IPv6 DNS Update 

#!/bin/bash

# Update no-ip with IPv6 address

USERNAME="[USERNAME]"
PASSWORD="[PASSWORD]"
DOAMIN="[DOMAIN]"

# Get current IPv6
IPV6=$(curl -s https://ipv6.ident.me/)

# Update No-IP
curl -s "https://${USERNAME}:${PASSWORD}@dyn.dns.he.net/nic/update?hostname=${DOAMIN}&myip=${IPV6}"
