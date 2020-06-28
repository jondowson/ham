#!/usr/local/bin/bash

# script_name: config_hosts.sh
# author: jd
# about: update the hosts and hostname files so that names can be used to reference machines

# n.b.: keep trying command over network until it succeeds: until ssh .....;do :; done
# n.b.: enable script to bypass console security question: -oStrictHostKeyChecking=no

function config_hostname(){

# The req'd variables are passed in this order:
# 1) the name of the pem key required to access this server.
# 2) ${prvIp} or ${pubIp} - public or private ip used to connect to server.
# 3) the server name.

# replace first line of /etc/hostname file to name of server
echo "${LOGO}-INFO: changing /etc/hostname file to: ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i '1s/.*/${3}/g' /etc/hostname"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function config_hosts(){

# The req'd variables are passed in this order:
# 1) the name of the pem key required to access this server.
# 2) ${prvIp} or ${pubIp} - public or private ip used to connect to server.
# 3) the server name.
# 4) the private ip of this amazon server

# insert after line 1 this server's private ip followed by the server name
echo "${LOGO}-INFO: inserting into /etc/hosts file: ${4} ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i '1a${4} ${3}' /etc/hosts"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function config_hosts_dse(){

# The req'd variables are passed in this order:
# 1) the name of the pem key required to access this server.
# 2) ${prvIp} or ${pubIp} - public or private ip used to connect to server.
# 3) private ip of this amazon server
# 4) insert line count

# insert after line 1 this server's private ip followed by the server name
echo "${LOGO}-INFO: inserting into /etc/hosts file: ${3} ${cluster_prvIp_name[${3}]}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i '${4}a${3} ${cluster_prvIp_name[${3}]}' /etc/hosts"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function config_push_hosts(){

# The req'd variables are passed in this order:
# 1) the name of the pem key required to access this server.
# 2) ${prvIp} or ${pubIp} - public or private ip used to connect to server.
# 3) the server name.

# restart hostname service
echo "${LOGO}-INFO: restarting hostname service on server ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo service hostname restart"; do :; done > \
${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

# call hostname
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo hostname"; do :; done > \
${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}
