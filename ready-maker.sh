echo "Getting Systeminfo..."
ipv6=$(ip -6 addr show dev eth0 scope global | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')
echo "$ipv6"
clear

echo "Do you want to setup NO-IP-DUC? (Y/n)"
read noipyn
clear
echo "Do you want to setup Apache-DUC? (Y/n)"
read apacheyn
echo "Setup can beginn"

if [ $noipyn == 'Y' ] || [ $noipyn == 'y' ]
then
    apt update && apt upgrade -y
    apt install wget python3 -y
    cd /root/
    wget https://nextcloud.longrise.biz/download/noipduc.service
    clear
    echo "What is your E-Mail from NO-IP?"
    read noip-email
    clear
    echo "What is your Password from NO-IP?"
    read noip-password
    clear
    echo "What is the Domain that you want to update?"
    echo noip-domain
    clear
    printf "account = ('$noipemail', '$noippassword')\ntoBeUpdated = '$noipdomain'\nwhichOne = 1\nupdateFrequency = 10\nimport requests\nimport subprocess\nfrom time import sleep\nimport os\nupdateurl = "http://dynupdate.no-ip.com/nic/update"\nlastaddr = str() \nwhile True:\n    hostnameReturn = subprocess.Popen("hostname -I", shell=True, stdout=subprocess.PIPE)\n    ipv6addrs = hostnameReturn.stdout.read()\n	   ipv6addr = str(ipv6addrs).split(' ')[whichOne]\n	   print(ipv6addr)  # print out just to be sure\n    parameters = {'hostname': toBeUpdated, 'myipv6': ipv6addr}\n    requestHeader = {'User-Agent': 'Personal noipv6-duc_1_0.py/linux-v5.0'}\n    if lastaddr != ipv6addr:\n        lastaddr = ipv6addr # update the latest ip address\n         serverreturn = requests.get(url = updateurl, params = parameters, auth=account)\n         if(serverreturn.status_code == 911):\n            print("Updating paused. No-IP server asks to stop requesting due to a server-side error for 30 minutes.")\n            sleep(1800) # sleep 1800 seconds = 30 minutes\n        print(serverreturn.url)\n         print(serverreturn.text)\n        os.system('/root/duc.sh')\n         print("updated. noice job!")\n    sleep(updateFrequency)" > /root/noipduc.py
    printf "[Unit]\nDescription=NOIPDUC\n\n[Service]\nType=simple\nExecStart=/bin/python3 /root/noipduc.py\nRestart=always\nRestartPreventExitStatus=yes\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/noipduc.service
    systemctl daemon-reload
    systemctl start noipduc.service
    systemctl status noipduc.service
    crontab -l > mycron
    printf "3 * * * * /bin/bash /root/duc.sh && /bin/systemctl restart noipduc\n@reboot /bin/bash /root/duc.sh && /bin/systemctl restart noipduc" >> mycron
    crontab mycron
    rm mycron
    echo "NOIP-DUC is installd!!!"
else
    apt update && apt upgrade -y
    echo "NOIP-DUC dont get installd"
fi

clear

if [ $apache-yn == 'Y' ] || [ $apache-yn == 'y' ]
then
    cd /root/
    apt install apache2 certbot python3 python3-certbot-apache php
    wget https://nextcloud.longrise.biz/download/duc.sh
    chmod 777 duc.sh
else
    echo "Apache dont get installed"
fi

 