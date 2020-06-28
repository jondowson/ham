#!/usr/local/bin/bash

# script_name: stop_app_instance.sh
# author: jd
# about: stop specific application(s) - determined by Application tag on AWS UI - on specific servers
#        ... optionally stop the instance as well - determined by passed boolean flag


function stop_app() {

# incoming variables:
# ${1} menu name | ${2} application | ${3} pem key | ${4} server ip | ${5} stop server flag

# format output:
menu_check "top" ${1}

# rename incoming variables:
application=${2}
key=${3}
serverIp=${4}
sleepInstance=${5}

# get hostname - better bet private ip - used when draining dse nodes
if [ "${MODE}" == "local" ];then
    hostname="${pubIps_prvIps[${serverIp}]}"
else
    hostname="${serverIp}"
fi

# for each type of application listed in Applications tag on Amazon UI...
# ...call the approprate stop script in /execute/remote/stop/stop_apps.sh

if [ ${application} == "cassandra" ]; then
    if [ "${sleepInstance}" == "true" ]; then
        stop_dse_sleep ${key} ${serverIp} ${hostname} ${application}
    else
        stop_dse_app ${key} ${serverIp} ${hostname} ${application}
    fi
elif [ ${application} == "spark" ]; then
    if [ "${sleepInstance}" == "true" ]; then
        stop_dse_sleep ${key} ${serverIp} ${hostname} ${application}
    else
        stop_dse_app ${key} ${serverIp} ${hostname} ${application}
    fi
elif [ ${application} == "solr" ]; then
    if [ "${sleepInstance}" == "true" ]; then
        stop_dse_sleep ${key} ${serverIp} ${hostname} ${application}
    else
        stop_dse_app ${key} ${serverIp} ${hostname} ${application}
    fi
elif [ ${application} == "opscenter" ]; then
    stop_opscenter ${key} ${serverIp}

elif [ ${application} == "mysql" ]; then
    stop_mysql ${key} ${serverIp}

elif [ ${application} == "nginx_lb" ]; then
    stop_nginx_lb ${key} ${serverIp}

elif [ ${application} == "nginx_a42_aml" ]; then
    stop_nginx_a42_aml ${key} ${serverIp}

elif [ ${application} == "nginx_ws" ]; then
    stop_nginx_ws ${key} ${serverIp}

elif [ ${application} == "None" ]; then
    echo "${LOGO}-INFO: define an Application for this server on AWS UI !!"
    echo "${LOGO}-INFO: not stopping any software !!"

elif [ ${application} == "undefined" ]; then
    echo "${LOGO}-INFO: application listed as 'undefined' on AWS UI !!"
    echo "${LOGO}-INFO: not stopping any software !!"
else
    echo "${LOGO}-INFO: stop_app_specific.sh - no such server type defined !!"
fi

# also stop the instance if passed flag is 'true'
if [ "${sleepInstance}" == "true" ]; then
    instanceId=${ips_instanceIds[${serverIp}]}
    serverName=${ips_names[${serverIp}]}
    stop_instance ${instanceId} ${serverName}
    if [  ${application} != "undefined" ] && [  ${application} != "None" ]; then
        timecount "30" "${LOGO}-INFO: 30 second pause for application ${application} to stop"
    fi
fi

echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
exit -1
}
