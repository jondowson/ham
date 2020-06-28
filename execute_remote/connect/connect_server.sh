#!/usr/local/bin/bash

# script_name: connect_server.sh
# author: jd
# about: connect to remote servers

# open an ssh shell on the remote server using the passed variables
function connect_ssh(){

# incoming variables:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

ssh -i ${KEYS}${1}.pem ubuntu@${2}
}

# open a cqlsh shell on the remote server using the passed variables
function connect_cqlsh(){

# incoming variables:
# 1) name of pem associated with server
# 2) 'pubIp/prvIp' - IP associated with server

ssh -t -i ${KEYS}${1}.pem ubuntu@${2} cqlsh ${2}
}
