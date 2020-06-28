#!/usr/local/bin/bash

# script_name: stop_apps.sh
# author: jd
# about:  stop apps on servers by description tag type

# n.b.: keep trying command over network until it succeeds: until ssh .....;do :; done
# n.b.: enable script to bypass console security question: -oStrictHostKeyChecking=no

function stop_dse_sleep(){

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server
# 3) name of server as specified in /etc/hostname or private ip
# 4) ring type

echo "${LOGO}-INFO: draining ${4} dse node at: ${2}"
cmd="nodetool drain -h ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'${cmd}'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: stopping dse service at: ${2}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service dse stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: stopping dse agent at: ${2}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service datastax-agent stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function stop_dse_app(){

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server
# 3) name of server as specified in /etc/hostname or private ip
# 4) ring type

echo "${LOGO}-INFO: draining ${4} dse node at: ${2}"
cmd="nodetool drain -h ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'${cmd}'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: stopping dse service at: ${2}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service dse stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}


function stop_opscenter() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo "${LOGO}-INFO: stopping opscenter at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service opscenterd stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function stop_mysql() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo "${LOGO}-INFO: stopping mysql at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo stop mysql'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function stop_nginx_lb() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo "${LOGO}-INFO: stopping nginx_lb at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'source lb_setup stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function stop_nginx_a42_aml() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo "${LOGO}-INFO: stopping nginx_a42_aml at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'source /home/ubuntu/semblent/a42-webserver/vac2/computecore2/manage.sh stop'; do :; done > \
${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function stop_nginx_ws() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo "${LOGO}-INFO: stopping nginx_ws at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service nginx stop'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}
