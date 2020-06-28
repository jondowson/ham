#!/usr/local/bin/bash

# script_name: build_server.sh
# author: jd
# about: read in user options to build server(s) from aws images

build_server(){

# formatting output
menu_check "top" $1

# steps to build a server
# 1) aws_cluster_config:   choose ami, vpc and subnet for cluster
# 2) server_setup:         specify number of servers
#                          + name, server type, key and security group and then build
#                          + configure hostname on server

aws_config
server_choices

# format output
menu_check "bottom" $1
}


#(1)*********************************aws_cluster_config

#(1.1)----------------------------which-ami-?

function aws_config(){

echo ""
echo ">>>>>>>>>>>>>>> which-ami-?"
declare -a amiId_array
loopcount=1
for i in "${!amiId_amiName[@]}"; do
    printf "%-1s) %-25s | %-20s\n" ${loopcount} ${amiId_amiName[$i]} ${i}
    amiId_array[$(($loopcount-1))]=${i}
    amiName=${amiId_amiName[$i]}
    let loopcount=loopcount+1
done

read user_choice
check_input "image"
# assign selected vpc Id to variable - this is used in the aws build call
amiId=${amiId_array[$(($user_choice-1))]}

#(1.2)----------------------------which-vpc-?

echo ""
echo ">>>>>>>>>>>>>>> which-vpc-?"
declare -a vpcId_array
loopcount=1
for i in "${!vpcid_vpcname[@]}"; do
    printf "%-1s) %-25s | %-20s\n" ${loopcount} ${vpcid_vpcname[$i]} ${i}
    vpcId_array[$(($loopcount-1))]=${i}
    let loopcount=loopcount+1
done

read user_choice
check_input "vpc"
# assign selected vpc Id to variable - this is used in the aws build call
vpcId=${vpcId_array[$(($user_choice-1))]}

#(1.3)----------------------------which-vpc-subnet-?

echo ""
echo ">>>>>>>>>>>>>>> which-subnet-?"
declare -a subnetId_array
loopcount=1
# match possible subnets to choosen parent vpc
for i in "${!subnetid_vpcid[@]}"; do
    if [ ${subnetid_vpcid[${i}]} == ${vpcId} ]; then
        # loop through this array to find matching groupname
        for j in "${!subnetid_region[@]}"; do
            if [ ${j} == ${i} ]; then
                printf "%-1s) %-25s | %-20s\n" ${loopcount} ${subnetid_region[${j}]} ${i}
                # capture all the valid subnet ids in this array - will be mapped to user selection
                subnetId_array[$(($loopcount-1))]=${i}
                let loopcount=loopcount+1
            fi
        done
    fi
done

read user_choice
check_input "subnet"
# assign selected subnet Id to variable - this is used in the aws build call
subnetId=${subnetId_array[$(($user_choice-1))]}
}


#(2)*********************************server_choices

function server_choices(){

# how many servers do we want to build from this image?
echo ""
echo ">>>>>>>>>>>>>>> how-many-servers-?"
read user_choice
check_input "number_of_servers"

totalServerCount=$user_choice
# populate these tags with something - used by build_dse_cluster.sh
nodeType="undefined"
clusterName="undefined"

#-----------------------------------------------------------------------------loop-each-server
serverCount=1
while [ ${serverCount} -lt $((totalServerCount +1)) ]; do

#(2.1)----------------------------server-name-?

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-name-?"
    read serverName

#(2.2)----------------------------server-type-?

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-type-?"
    # alas no aws call to get this - so static list
    declare -A type_array=([1]=t2.micro [2]=t2.small [3]=t2.medium [4]=m3.medium \
                          [5]=m3.large [6]=m3.xlarge [7]=m3.2xlarge)
    loopcount=1
    for i in "${!type_array[@]}"
    do
        echo "${loopcount}) ${type_array[$i]}"
        let loopcount=loopcount+1
    done

    read user_choice
    check_input "type"
    # assign selected server type to variable - this is used in the aws build call
    serverType=${type_array[$user_choice]}

#(2.3)----------------------------server-key-?

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-pem-key-?"
    loopcount=1
    readarray -t key_array < ${TABLES}keypairs.txt
    for i in "${key_array[@]}"
    do
        printf "%-1s) %-25s\n" ${loopcount} ${key_array[$(($loopcount-1))]}
        let loopcount=loopcount+1
    done

    read user_choice
    check_input "key"
    # assign server key to variable - this is used in the aws build call
    serverKey=${key_array[$(($user_choice-1))]}

#(2.4)----------------------------server-security-group-?

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-security-group-?"
    # array used to match security group ids (req'd to build server) to user choice
    declare -a secgroupId_array
    # count used for numerical user choice and to refer to arrays when one has been minused (arrays start at zero)
    loopcount=1
    # loop - match security group ids that belong to the already selected vpc id
    for i in "${!secgroupid_vpcid[@]}"; do
        if [ ${secgroupid_vpcid[${i}]} == ${vpcId} ]; then
            # loop through this array to find matching groupname
            for j in "${!secgroupid_groupname[@]}"; do
                if [ ${j} == ${i} ]; then
                    printf "%-1s) %-25s | %-20s\n" ${loopcount} ${secgroupid_groupname[${j}]} ${i}
                    # capture all the security group ids in this array - will be mapped to user selection
                    secgroupId_array[$(($loopcount-1))]=${i}
                    let loopcount=loopcount+1
                fi
            done
        fi
    done

    read user_choice
    check_input "sg"
    # assign selected security group Id to variable - this is used in the aws build call
    secgroupId=${secgroupId_array[$(($user_choice-1))]}

#(2.5)----------------------------build-server-?

    echo ""
    echo "---------------------------------------------------"
    echo "${LOGO}-INFO: building server ${serverCount} using image: ${amiName}"
    # building one at a time
    howMany=1
    instances_build ${amiId} ${howMany} ${serverType} ${serverKey} ${secgroupId} \
    ${subnetId} ${serverName} ${nodeType} ${clusterName}

#(2.6)----------------------------configure-server-hostname-?

    # read the newInstance_ips.txt file and get the tab seperated public/private ips into an array
    declare -A newInstance_pubIp_prvIP
    while IFS=$'\t' read -r -a myArray
    do
        newInstance_pubIp_prvIP[${myArray[0]}]=${myArray[1]}
    done < ${TABLES}newInstance_ips.txt

    for pubIp in "${!newInstance_pubIp_prvIP[@]}"
    do
        prvIp=${newInstance_pubIp_prvIP[${pubIp}]}
        if [ ${MODE} == "server" ]; then
            ip=${newInstance_pubIp_prvIP[${pubIp}]}
        else
            ip=${pubIp}
        fi
    done

    echo "${LOGO}-INFO: ...waiting for telnet to confirm server boot up"
    echo quit | telnet ${ip} 22 2>/dev/null | grep Connected

    config_hostname ${serverKey} ${ip} ${serverName}
    config_hosts ${serverKey} ${ip} ${serverName} ${prvIp}
    config_push_hosts ${serverKey} ${ip} ${serverName}

    # tidy up temp file
    rm ${TABLES}newInstance_ips.txt

    # main loop counter
    let serverCount=serverCount+1
done

echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
exit -1
}


#************************************input-checker

function check_input(){

if [ "$1" == "number_of_servers" ]; then
    while ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 1 -o "$user_choice" -gt 8 ]; do
        echo "...invalid choice - enter a number between 1 and 8"
        read user_choice
    done
else
    while ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 1 -o "$user_choice" -gt "$(($loopcount-1))" ]; do
        echo "...invalid choice - choose number in range"
        read user_choice
    done
fi

}
