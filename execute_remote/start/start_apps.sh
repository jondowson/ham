#!/usr/local/bin/bash

# script_name: start_apps.sh
# author: jd
# about:  start apps on servers by description tag type

# n.b.: keep trying command over network until it succeeds: until ssh .....;do :; done
# n.b.: enable script to bypass console security question: -oStrictHostKeyChecking=no

function start_dse_sleep(){

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) pubIp/prvIp - IP associated with server
# 3) nodetype - type of DSE node
# 4) public ip - req'd for setting in cassandra-env.sh

# reassign incoming variables to meaningful names:
key=${1}
serverIp=${2}
nodeType=${3}
pubIp=${4}

JVM="\$JVM_OPTS"
echo "${LOGO}-INFO: starting ${nodeType} node at: ${serverIp}"
echo "${LOGO}-INFO: updating <public name> in cassandra-env.sh to: ${pubIp}"
# assign the public ip of this server to address local access issues for shell connections
until ssh -i ${KEYS}${key}.pem ubuntu@${serverIp} -o StrictHostKeyChecking=no \
'sudo sed -i "s@JVM_OPTS=\"\\\$JVM_OPTS -Djava.rmi.server.hostname=.*\"@JVM_OPTS=\"\\\$JVM_OPTS -Djava.rmi.server.hostname=${pubIp}\"@g" /etc/dse/cassandra/cassandra-env.sh'; do :; done \
>${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: starting dse agent for ${nodeType} node at: ${serverIp}"
until ssh -i ${KEYS}${key}.pem ubuntu@${serverIp} -oStrictHostKeyChecking=no \
'sudo service datastax-agent restart'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: starting dse service for ${nodeType} node at: ${serverIp}"
until ssh -i ${KEYS}${key}.pem ubuntu@${serverIp} -oStrictHostKeyChecking=no \
'sudo service dse restart'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
timecount "${DSE_RESTART}" "${LOGO}-INFO: ${DSE_RESTART} second pause to allow dse to restart"

}

function start_dse_app(){

# incoming variables:
# 1) name of pem associated with server
# 2) pubIp/prvIp - IP associated with server
# 3) nodetype - type of DSE node

# reassign incoming variables to meaningful names:
key=${1}
serverIp=${2}
nodeType=${3}

echo "${LOGO}-INFO: starting ${nodeType} node at: ${serverIp}"
echo "${LOGO}-INFO: restarting dse agent for node at: ${serverIp}"
until ssh -i ${KEYS}${key}.pem ubuntu@${serverIp} -oStrictHostKeyChecking=no \
'sudo service datastax-agent restart'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: starting dse service for node at: ${serverIp}"
until ssh -i ${KEYS}${key}.pem ubuntu@${serverIp} -oStrictHostKeyChecking=no \
'sudo service dse restart'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
timecount "${DSE_RESTART}" "${LOGO}-INFO: ${DSE_RESTART} second pause to allow dse to restart"

}

function start_opscenter() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo ""
echo "${LOGO}-INFO: starting opscenter at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service opscenterd start'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function start_mysql() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server
echo ""
echo "${LOGO}-INFO: starting mysql at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo start mysql'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function start_nginx_lb() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo ""
echo "${LOGO}-INFO: starting nginx_lb at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'source lb_setup start'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function start_nginx_a42_aml() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo ""
echo "${LOGO}-INFO: starting nginx_a42_aml at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'source /home/ubuntu/semblent/a42-webserver/vac2/computecore2/manage.sh start'; do :; done > \
${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}

function start_nginx_ws() {

# The req'd variables are passed in this order:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

echo ""
echo "${LOGO}-INFO: starting nginx_ws at: ${2}"
echo ""
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no \
'sudo service nginx start'; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
}
