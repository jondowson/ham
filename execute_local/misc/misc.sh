#!/usr/local/bin/bash

# script_name: misc.sh
# author: jd
# about: various misc functions

function modify_subnet_pubips(){
# this info is required to turn on auto public ips for dev vpc

declare -a dev_subnetId_array
loopcount=1
# match possible subnets to choosen parent vpc
for i in "${!subnetid_vpcid[@]}"; do
    if [ "${subnetid_vpcid[${i}]}" == "${1}" ]; then
        dev_subnetId_array[$(($loopcount-1))]=${i}
        let loopcount=loopcount+1
    fi
done

for i in "${dev_subnetId_array[@]}"
do
   modify_subnet_attribute "${i}"
done
}

# -----------------------------------------------------------------------------------

function get_public_ip(){
# determine public ip
PUBLIC_IP=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
}

# -----------------------------------------------------------------------------------

function get_private_ip(){
PRIVATE_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d: -f2 | awk '{print $1}')
}

# -----------------------------------------------------------------------------------

function get_private_ip_mac(){
PRIVATE_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d: -f2 | awk '{print $2}')
}

# -----------------------------------------------------------------------------------

function timecount(){
    min=0
    sec=${1}
    message=${2}
    echo "${2}"
    while [ ${min} -ge 0 ]; do
          while [ ${sec} -ge 0 ]; do
              echo -ne "00:0$min:$sec\033[0K\r"
              sec=$((sec-1))
              sleep 1
          done
          sec=59
          min=$((min-1))
   done
}
