#!/usr/local/bin/bash

# script_name: start_instance.sh
# author: jd
# about: call amazon account to start a server from a stopped state

function start_instance(){

# incoming variables:
# 1) ${1} instance Id
# 2) ${2} server name

echo "${LOGO}-INFO: starting server ${2} with instance-id: ${1}"
aws ec2 start-instances --instance-ids ${1} > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null &
}
