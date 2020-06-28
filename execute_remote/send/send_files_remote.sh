#!/usr/local/bin/bash

# script_name: send_files_remote.sh
# author: jd
# about: transfer files to and from remote machines

#---------------------------------------------------------------------------AWS-CALLS-build-servers

function send_scp(){

# variables are passed in this order:
# 1) port number
# 2) ssh key
# 3) file to send
# 4) remote user
# 5) remote ip

if [[ ${2} == *".pem"* ]]
then
    key=${2}
else
    key=${2}.pem
fi

if [[ ${2} == "password" ]]; then
    sudo scp -r -P ${1} ${3} ${4}@${5}:~/
else
    if [[ ${2} == *".pem"* ]]
    then
        key=${2}
    else
        key=${2}.pem
    fi
    sudo scp -r -P ${1} -i ${key} ${3} ${4}@${5}:~/
fi
}

function get_scp_key(){

# variables are passed in this order:
# 1) port
# 2) ssh key
# 3) remote user
# 4) remote ip

if [[ ${2} == *".pem"* ]]
then
    key=${2}
else
    key=${2}.pem
fi

remotefile="sudo sftp -P ${1} -i ${key} ${3}@${4}"

echo ""
echo "${b}${yellow}YOU ARE NOW CONNECTED TO REMOTE MACHINE VIA SFTP!!${reset}"
echo ""
echo "${b}${cyan}Instructions:${reset}${white}"
echo "1) double tap [tab] to see list of sftp instructions"
echo "2) use 'ls' to list and 'cd' to change directory"
echo "3) use 'get' to retrieve a file and type 'bye' or 'quit' to exit back to HAM"
echo ""
${remotefile}
}

function get_scp_password(){

# variables are passed in this order:
# 1) port
# 2) remote user
# 3) remote ip

remotefile="sudo sftp -P ${1} ${2}@${3}"

echo ""
echo "${b}${yellow}YOU ARE NOW CONNECTED TO REMOTE MACHINE VIA SFTP!!${reset}"
echo ""
echo "${b}${cyan}Instructions:${reset}${white}"
echo "1) double tap [tab] to see list of sftp instructions"
echo "2) use 'ls' to list and 'cd' to change directory"
echo "3) use 'get' to retrieve a file and type 'bye' or 'quit' to exit back to HAM"
echo ""

${remotefile}
}
