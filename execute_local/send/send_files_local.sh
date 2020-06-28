#!/usr/local/bin/bash

# script_name: send_files_local.sh
# author: jd
# about: read in user options to send files to and from this computer

function util_get_files(){

# formatting output
menu_check "top" $1

echo "*** ${b}${cyan}SCP TRANSFER FILE FROM REMOTE MACHINE TO HERE${reset}"
echo ""

# which user account are we connecting to on remote machine
echo "${white}>> ${cyan}remote machine user? ${white} username [enter] or just hit [enter] for ubuntu"
read remote_user
if [ "${remote_user}" == "" ]; then
    remote_user="ubuntu"
fi

# which port number shall we use on both machines for transfer
echo ">> ${cyan}what port number to use in transfer ? ${white}e.g. 3000 [enter] or just hit [enter] to use 22"
echo ".. ensure this port is open on both servers"
echo ".. router settings usually found at http://192.168.1.1/"
read port
if [ "${port}" == "" ]; then
    port="22"
fi

# what is the ip address of the remote machine
echo ">> ${cyan}remote machine IP ? ${white}ip address x.x.x.x [enter] OR just hit [enter] for an aws server"
echo ".. you can run 'ifconfig' on remote machine if you need to identify its ip"
echo ".. use public ip to connect if machines are on different networks"
read remote_ip

# if remote machine is in aws cloud -  present menu to get ip and ssh key
if [ "${remote_ip}" == "" ]; then
    echo ""
    dynamic_menus_inline "get_scp_key" ${remote_user} ${port} "oink"
    source ${MENUS}dmenu-inline_get_scp_key.sh
    dmenu-inline_get_scp_key
else
    echo ">> ${cyan}ssh key or password only auth ? ${white}full-key-file-path [enter] or hit [enter] for password auth"
    echo ".. ${white}select ssh key including full file path [enter] - autocomplete available [tab]"
    currentdirectory="${PWD}"
    cd ${KEYS}
    read -e -p ${KEYS} sshkey
    remote_ssh_key="${KEYS}${sshkey}"
    cd ${currentdirectory}

    # if user is not using a key but instead is providing a password
    if [ "${sshkey}" = "" ]; then
        # which user account are we connecting to on remote machine
        #echo "${white}>> ${cyan}enter full remote filepath of transfer file ? ${white}e.g. /home/dave/test.txt [enter]"
        #read remote_file
        #echo ">> ${b}${cyan}NOW TRANSFERRING REMOTE FILE ${reset}${remote_file} ${b}${cyan}TO LOCAL FOLDER: ${reset}${HOME}"
        get_scp_password ${port} ${remote_user} ${remote_ip}
    # user has chosen a local ssh key to connect with
    else
        get_scp_key ${port} ${remote_ssh_key} ${remote_user} ${remote_ip}
    fi
fi

menu_check "bottom" $1
}

function util_send_files(){

# formatting output
menu_check "top" $1


echo "*** ${b}${cyan}SCP TRANSFER FILE FROM HERE TO REMOTE MACHINE${reset}"
echo ""
echo ">> ${cyan}select file from current or root directory ? ${white}just hit [enter] for current - r [enter] for root directory"
read tree

# list current directory or from root
if [ "${tree}" == "r" ]; then
    currentdirectory="${PWD}"
    cd /
    echo ">> ${cyan}full file path to transfer file ? ${white}- autocomplete available [tab]"
    read -e -p ${PWD}/ tf
    transfer_file="${PWD}/${tf}"
    cd ${currentdirectory}
else
    echo ">> ${cyan}full file path to transfer file ? ${white}- autocomplete available [tab]"
    read -e -p ${PWD}/ tf
    transfer_file="${PWD}/${tf}"
fi

# which user account are we connecting to on remote machine
echo ""
echo "${white}>> ${cyan}remote machine user? ${white} username [enter] or just hit [enter] for ubuntu"
read remote_user
if [ "${remote_user}" == "" ]; then
    remote_user="ubuntu"
fi

# which port number shall we use on both machines for transfer
echo ">> ${cyan}what port number to use in transfer ? ${white}e.g. 3000 [enter] or just hit [enter] to use 22"
echo ".. ensure this port is open on both servers"
echo ".. router settings usually found at http://192.168.1.1/"
read port
if [ "${port}" == "" ]; then
    port="22"
fi

# what is the ip address of the remote machine
echo ">> ${cyan}remote machine IP ? ${white}ip address x.x.x.x [enter] OR just hit [enter] for an aws server"
echo ".. you can run 'ifconfig' on remote machine if you need to identify its ip"
echo ".. use public ip to connect if machines are on different networks"
read remote_ip

# if remote machine is in aws cloud - lets use a menu to get ip and ssh key
if [ "${remote_ip}" == "" ]; then
    dynamic_menus_inline "send_scp" ${remote_user} ${port} ${transfer_file}
    source ${MENUS}dmenu-inline_send_scp.sh
    dmenu-inline_send_scp
else
    echo ">> ${cyan}ssh key or password only auth ? ${white}full-key-file-path [enter] or just hit [enter] for password auth"
    echo ".. ${white}enter ssh key including full file path [enter] - autocomplete available [tab]"
    currentdirectory="${PWD}"
    cd ${KEYS}
    read -e -p ${KEYS} sshkey
    cd ${currentdirectory}

    if [ "${sshkey}" = "" ]; then
        remote_ssh_key="password"
    else
        remote_ssh_key="${KEYS}${sshkey}"
    fi

    echo ">> ${b}${cyan}NOW TRANSFERRING LOCAL FILE ${reset}${transfer_file} ${b}${cyan}TO REMOTE FOLDER: ${reset}/home/${remote_user}"
    send_scp ${port} ${remote_ssh_key} ${transfer_file} ${remote_user} ${remote_ip}
fi

menu_check "bottom" $1
}
