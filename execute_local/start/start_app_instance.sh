#!/usr/local/bin/bash

# script_name: start_app_instance.sh
# author: jd
# about: start specific application(s) - determined by Application tag on AWS UI - on specific servers

function start_specific() {

# incoming variables:
# ${1} menu name | ${2} application | ${3} pem key | ${4} server ip

# rename incoming variables
application=${2}
key=${3}
serverIp=${4}
sleepFlag="false"

# format output
menu_check "top" ${1}

echo "n.b.: any instances in a stopped state will be awoken !!"
echo "n.b.: nodes already running will have application(s) restarted !!"
echo ""

# steps to start the application on a specific server
# 1) instance_state: check to see if this instance needs to be awoken from sleep
# 2) start_apps:     start the specific application(s) on this specific server

# start the appropriate app
instance_state
start_app

# format output
menu_check "bottom" ${1}
}

#(1)*********************************instance_state

function instance_state(){

# for stopped server we need to get the instance-id
# no public ip is available so get
if [[ "${serverIp}" == *"i"* ]]; then

    sleepFlag="true"

    instanceId=${serverIp}
    serverName=${instanceId_name[${instanceId}]}

    start_instance ${instanceId} ${serverName}
    timecount "${AWAKEN}" "${LOGO}-INFO: ${AWAKEN} second pause for ${serverName} to be awoken from sleep"

    # refresh local list of instances
    echo "${LOGO}-INFO: refreshing ham tables and arrays"
    tables_refresh
    source ${TABLES}tables_arrays.sh

    # retrieve new public ip and assign to script variable
    if [ "${MODE}" == "local" ];then
        serverIp=${instanceId_pubIps[${instanceId}]}
    else
        serverIp=${instanceId_prvIps[${instanceId}]}
    fi
fi
}

#(2)*********************************start_app

function start_app(){
# for each type of application listed in Applications tag on Amazon UI...
# ...call the approprate start script in /execute/remote/start/start_apps.sh

# source the table arrays that were refreshed by instance_state() function
source ${TABLES}tables_arrays.sh

if [ "${MODE}" == "local" ];then
    hostname=${pubIps_prvIps[${serverIp}]}
    pubIp=${serverIp}
else
    hostname=${serverIp}
    pubIp=${prvIp_pubIp[${serverIp}]}
fi

if [ ${application} == "cassandra" ]; then
    if [ "${sleepFlag}" == "true" ]; then
        start_dse_sleep ${key} ${serverIp} ${application} ${pubIp}
    else
        start_dse_app ${key} ${serverIp} ${application} ${pubIp}
    fi

elif [ ${application} == "spark" ]; then
    if [ "${sleepFlag}" == "true" ]; then
        start_dse_sleep ${key} ${serverIp} ${application} ${pubIp}
    else
        start_dse_app ${key} ${serverIp} ${application} ${pubIp}
    fi

elif [ ${application} == "solr" ]; then
    if [ "${sleepFlag}" == "true" ]; then
        start_dse_sleep ${key} ${serverIp} ${application} ${pubIp}
    else
        start_dse_app ${key} ${serverIp} ${application} ${pubIp}
    fi

elif [ ${application} == "opscenter" ]; then
    start_opscenter ${key} ${serverIp} ${application}

elif [ ${application} == "mysql" ]; then
    start_mysql ${key} ${serverIp} ${application}

elif [ ${application} == "nginx_lb" ]; then
    start_nginx_lb ${key} ${serverIp} ${application}

elif [ ${application} == "nginx_a42_aml" ]; then
    start_nginx_a42_aml ${key} ${serverIp} ${application}

elif [ ${application} == "nginx_ws" ]; then
    start_nginx_ws ${key} ${serverIp} ${application}

elif [ ${application} == "None" ]; then
    echo "${LOGO}-INFO: define an Application for this server on AWS UI !!"
    echo "${LOGO}-INFO: not starting any software !!"

elif [ ${application} == "undefined" ]; then
    echo "${LOGO}-INFO: application listed as 'undefined' on AWS UI !!"
    echo "${LOGO}-INFO: not starting any software !!"
else
    echo "${LOGO}-INFO: start_app_specific.sh - no such server type defined !!"
fi

echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
exit -1
}
