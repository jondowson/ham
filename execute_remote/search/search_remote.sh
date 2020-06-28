#!/usr/local/bin/bash

# script_name: search_remote.sh
# author: jd
# about: search remote machines

#---------------------------------------------------------------------------AWS-CALLS-build-servers

function search_remote_files(){

# variables are passed in this order:
# 1) port number
# 2) ssh key
# 3) search type + search term + search directory //comma separated
# 4) remote user
# 5) remote ip

# add file extension to ssh key variable if it does not exist
if [[ "${2}" == *".pem"* ]]
then
    key="${2}"
else
    key="${2}.pem"
fi

# split up the composite variable string parameter
IFS=',' read -r -a array <<< "${3}"
searchType="${array[0]}"
searchTerm="${array[1]}"
searchFolder="${array[2]}"

# search on remote machine for file by name
if [ "${searchType}" = "4files" ]; then
    echo ""
    echo ${b}${yellow}"Remote Search for files/directories named ${searchTerm} @${5}:${reset}"
    echo ""
    if [ "${2}" = "password" ]; then
        until sudo ssh -t ${4}@${5} \
        "sudo find ${searchFolder} -name ${searchTerm}"; do :; done
    else
        until ssh -i ${key} ${4}@${5} -o StrictHostKeyChecking=no \
        "sudo find ${searchFolder} -name ${searchTerm}"; do :; done
    fi

# search on remote machine for files containing a given string
else
    echo ""
    echo ${b}${yellow}"Remote Search for ${searchTerm} within files ${4}@${5}:${reset}"
    echo ""
    if [ "${2}" = "password" ];then
        until ssh -t ${4}@${5} \
        "sudo grep -oisrI '\<${searchTerm}\>' ${searchFolder} | sort | uniq -c"; do :; done
    else
        until ssh -i ${key} ${4}@${5} -o StrictHostKeyChecking=no \
        "sudo grep -oisrI '\<${searchTerm}\>' ${searchFolder} | sort | uniq -c"; do :; done
    fi
fi
}
