#!/usr/local/bin/bash

# script_name: stop_instance.sh
# author: jd
# about: call amazon account to stop a server from a running state

function stop_instance(){

# incoming variables:
# 1) ${1} instance Id
# 2) ${2} server name

echo "${LOGO}-INFO: entering sleep status for ${2} with instance-id: ${1}"
aws ec2 stop-instances --instance-ids ${1} > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null &
}
