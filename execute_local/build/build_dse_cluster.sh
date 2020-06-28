#!/usr/local/bin/bash

# script_name: build_dse_cluster.sh
# author: jd
# about: read in user options to build (or append to) DSE clusters(s) from aws images

build_dse_cluster(){

# format output
menu_check "top" "${1}"

# steps to build a dse cluster:
# 1) aws_cluster_config:   choose ami, vpc and subnet for cluster
# 2) dse_cluster_config:   name cluster and define number of spark, solr and cassandra nodes
# 3) dse_nodes_config:     for each node type define server name, type, key and sec group
# 4) configure_nodes:      dynamically update hosts/hostname files + dse config files
# 5) rolling_start:        start cluster rings one at a time (cassandra->analytics->solr)

# declare arrays required across functions in this script:
#   associative arrays set in configure_nodes() function
#   req'd also in rolling_start() function
declare -A cluster_prvIp_application
declare -A cluster_pubIp_application

# call functions in this order:
aws_cluster_config
dse_cluster_config
dse_nodes_config
configure_nodes
rolling_start

# format output:
menu_check "bottom" "${1}"
}


#(1)*********************************aws_cluster_config

function aws_cluster_config(){
#(1.1)-------------------------------choose-ami

# basic menu instructions
echo ""
echo ">>>>>>>>>>>>>>> which-ami-?"
echo ""
declare -a amiId_array
declare -a amiName_array
loopcount=1
for i in "${!amiId_amiName[@]}"; do
    printf "%-1s) %-25s | %-20s\n" "${loopcount}" "${amiId_amiName[$i]}" "${i}"
    amiId_array[$(($loopcount-1))]=${i}
    amiName_array[$(($loopcount-1))]=${amiId_amiName[$i]}
    let loopcount=loopcount+1
done

read user_choice
check_build_dse_input "ami"
# assign selected vpc Id to variable - this is used in the aws build call
amiId=${amiId_array[$(($user_choice-1))]}
amiName=${amiName_array[$(($user_choice-1))]}

#(1.2)-------------------------------choose-vpc

echo ""
echo ">>>>>>>>>>>>>>> which-vpc-?"
echo ""
declare -a vpcId_array
loopcount=1
for i in "${!vpcid_vpcname[@]}"; do
    printf "%-1s) %-25s | %-20s\n" "${loopcount}" ${vpcid_vpcname[$i]} ${i}
    vpcId_array[$(($loopcount-1))]=${i}
    let loopcount=loopcount+1
done

read user_choice
check_build_dse_input "vpc"
# assign selected vpc Id to variable - this is used in the aws build call
vpcId=${vpcId_array[$(($user_choice-1))]}

#(1.3)-------------------------------choose-vpc-subnet

echo ""
echo ">>>>>>>>>>>>>>> vpc-subnet-?"
echo ""
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
check_build_dse_input "vpcSubnet"
# assign selected subnet Id to variable - this is used in the aws build call
subnetId=${subnetId_array[$(($user_choice-1))]}
}


#(2)*********************************dse-cluster-config

function dse_cluster_config(){

#(2.1)-------------------------------name-cluster

# what name for the cluster?
echo ""
echo ">>>>>>>>>>>>>>> cluster-name-?"
echo ""
echo "n.b.: for new cluster pick new name"
echo "n.b.: these names are already in use:"

# array to include these two reserved words
declare -a unique_cluster_names=('None' 'undefined')

# remove duplicate candidates
for ip in "${!pubIps_cluster[@]}"; do
    ucn_count=0
    for name in "${!unique_cluster_names[@]}"; do
        if [ "${pubIps_cluster[$ip]}" == "${unique_cluster_names[${name}]}" ];then
            break
        else
            let ucn_count=ucn_count+1
        fi
        ucn_size=${#unique_cluster_names[@]}
        if [ "$ucn_count" == "${ucn_size}" ]; then
            unique_cluster_names[${ucn_size}+1]=${pubIps_cluster[$ip]}
        fi
    done
done

# display already in use cluster names
for name in "${unique_cluster_names[@]}"; do
    echo ${name}
done

read user_choice
clusterName=${user_choice}

#(2.2)-------------------------------number-of-cassandra-nodes

# how many cassandra nodes do you want in this DSE cluster?
echo ""
echo ">>>>>>>>>>>>>>> how-many-nodes-in-cassandra-ring-?"
echo ""
read user_choice
check_build_dse_input "number_of_servers"
cassCount=${user_choice}

#(2.3)-------------------------------number-of-spark-nodes

# how many spark nodes do you want in this DSE cluster?
echo ""
echo ">>>>>>>>>>>>>>> how-many-nodes-in-spark-ring?"
echo ""
read user_choice
check_build_dse_input "number_of_servers"
sparkCount=${user_choice}

#(2.4)-------------------------------number-of-solr-nodes

# how many solr nodes do you want in this DSE cluster?
echo ""
echo ">>>>>>>>>>>>>>> how-many-nodes-in-solr-ring-?"
echo ""
read user_choice
check_build_dse_input "number_of_servers"
solrCount=${user_choice}
}


#(3)*********************************dse_nodes_config

function dse_nodes_config(){

# loop through each dse node type for the specified number of servers
node_loop "cassandra" ${cassCount}
node_loop "spark" ${sparkCount}
node_loop "solr" ${solrCount}
}

#(3.1)-------------------------------node_loop

function node_loop(){

nodeType=${1}
totalServerCount=${2}

serverCount=1
while [ ${serverCount} -lt $((totalServerCount +1)) ]; do

    echo ""
    echo ">>>>>>>>>>>>>>> now define node ${serverCount} of ${totalServerCount} ${nodeType} nodes"

#(3.1.1)-------------------------------name-server

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-name-?"
    echo ""
    echo "n.b.: do not use underscores in name"
    echo ""
    read serverName

#(3.1.2)-------------------------------server-type

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-type-?"
    echo ""
    echo "n.b.: t2.small is the minimum size for datastax nodes"
    echo ""

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
    check_build_dse_input "serverType"
    # assign selected server type to variable - this is used in the aws build call
    serverType=${type_array[$user_choice]}

#(3.1.3)-------------------------------server-key

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-pem-key-?"
    echo ""

    loopcount=1
    readarray -t key_array < ${TABLES}keypairs.txt
    for i in "${key_array[@]}"
    do
        printf "%-1s) %-25s\n" ${loopcount} ${key_array[$(($loopcount-1))]}
        let loopcount=loopcount+1
    done

    read user_choice
    check_build_dse_input "serverKey"
    # assign server key to variable - this is used in the aws build call
    serverKey=${key_array[$(($user_choice-1))]}

#(3.1.4)-------------------------------security-group

    echo ""
    echo ">>>>>>>>>>>>>>> server-${serverCount}/${totalServerCount}:-security-group-?"
    echo ""

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
    check_build_dse_input "secGroup"
    # assign selected security group Id to variable - this is used in the aws build call
    secgroupId=${secgroupId_array[$(($user_choice-1))]}

#(3.1.5)-------------------------------build-server

    echo ""
    echo "${LOGO}-INFO: building ${nodeType} server-${serverCount} using image: ${amiName}"

    # we're building one at a time
    howMany=1

    instances_build ${amiId} ${howMany} ${serverType} ${serverKey} ${secgroupId}\
                    ${subnetId} ${serverName} ${nodeType} ${clusterName}

    rm ${TABLES}newInstance_ips.txt

    # main loop counter
    let serverCount=serverCount+1
done
}


#(4)*********************************configure_nodes

function configure_nodes(){

# find all servers by type in order to start the appropriate DSE scripts / services
# for each server identify node type and all req'd ips before calling the setup_dse_node function
# this will fire the remote commands to establish the type of dse node and update config scripts
# final job is to update the '/etc/hosts' file on all nodes in the same cluster with mappings to server names

# refresh local list of instances
echo ""
timecount "30" "${LOGO}-INFO: 30 second pause to allow new cluster server boot-up"

#(4.1)-------------------------------config-setup

# refresh local list of instances
echo "${LOGO}-INFO: refreshing ham tables and arrays"
tables_refresh
source ${TABLES}tables_arrays.sh

# get all private ips for this cluster, regardless of node type, into a comma separated 'seeds' string
seeds=""
# make associative array to capture prvIps:serverName for this cluster
declare -A cluster_prvIp_name

echo "${LOGO}-INFO: generating seed list for cluster ${clusterName}"
for ip in "${!prvIps_cluster[@]}"; do
    if [[ "${prvIps_cluster[${ip}]}" == "${clusterName}" ]]; then
        if [ "$seeds" == "" ]; then
            seeds=${ip}
            cluster_prvIp_name[${ip}]=${prvIps_name[${ip}]}
        else
            seeds+=",${ip}"
            cluster_prvIp_name[${ip}]=${prvIps_name[${ip}]}
        fi
    fi
done

#(4.2)-------------------------------config-nodes-loop

# loop through all nodes for this cluster
for prvIp in "${!cluster_prvIp_name[@]}"; do
    echo ""
    echo "---------------------------------------------------"
    echo "${LOGO}-INFO: configuring node ${cluster_prvIp_name[${prvIp}]}"

#(4.2.1)----------------------------server-connection-info

    # dependent on ham run MODE - connect using public or private ips
    pubIp="${prvIps_pubIps[${prvIp}]}"
    if [ ${MODE} == "server" ]; then
        connectIp=${prvIp}
    else
        connectIp=${pubIp}
    fi

    # get the security key for this node
    for prvIp2 in "${!prvIps_keys[@]}"; do
        if [[ ${prvIp} == ${prvIp2} ]]; then
            key="${prvIps_keys[${prvIp2}]}"
        fi
    done
        
    # get server name
    serverName=${cluster_prvIp_name[${prvIp}]}

#(4.2.2)----------------------------server-hosts-hostname

    # write hostname for node as server name
    config_hostname ${key} ${connectIp} ${serverName}

    # write new hosts file with all private ips and server names for cluster
    insertLine=1
    for privIp in "${!cluster_prvIp_name[@]}"; do
        config_hosts_dse ${key} ${connectIp} ${privIp} ${insertLine}
        let insertLine=insertLine+1
    done

    # update hosts/hostname - the no-reboot approach
    config_push_hosts ${key} ${connectIp} ${serverName}

#(4.2.3)----------------------------dse-node-type-config

    # populate these associative arrays used later in rolling start
    if [[ ${prvIps_application[${prvIp}]} == "spark" ]]; then
        flavour="spark"
    elif [[ ${prvIps_application[${prvIp}]} == "cassandra" ]]; then
        flavour="cassandra"
    else
        flavour="solr"
    fi
    cluster_prvIp_application[${prvIp}]="$flavour"
    cluster_pubIp_application[${prvIps_pubIps[${prvIp}]}]="$flavour"

    # configure node depending on node type
    config_dse_node ${key} ${connectIp} ${clusterName} ${flavour} ${prvIp} ${pubIp} ${seeds}
    echo "---------------------------------------------------"

done
}

#(5)*********************************rolling_start

function rolling_start() {

# source the arrays again as they were updated in the previous function
source ${TABLES}tables_arrays.sh

if [ "${MODE}" == "server" ]; then

    runOnce="true"
    for ip in "${!cluster_prvIp_application[@]}"; do
        if [[ "${cluster_prvIp_application[${ip}]}" == "cassandra" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting cassandra ring on ${clusterName}"
                runOnce="false"
            fi
            key="${prvIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting cassandra node at: ${ip}"
            start_dse_app ${key} ${ip} "cassandra"
        fi
    done

    runOnce="true"
    for ip in "${!cluster_prvIp_application[@]}"; do
        if [[ "${cluster_prvIp_application[${ip}]}" == "spark" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting analytics ring on ${clusterName}"
                runOnce="false"
            fi
            key="${prvIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting spark node at: ${ip}"
            start_dse_app ${key} ${ip} "spark"
        fi
    done

    runOnce="true"
    for ip in "${!cluster_prvIp_application[@]}"; do
        if [[ "${cluster_prvIp_application[${ip}]}" == "solr" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting solr ring on ${clusterName}"
                runOnce="false"
            fi
            key="${prvIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting solr node at: ${ip}"
            start_dse_app ${key} ${ip} "solr"
        fi
    done

else

    runOnce="true"
    for ip in "${!cluster_pubIp_application[@]}"; do
        if [[ "${cluster_pubIp_application[${ip}]}" == "cassandra" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting cassandra ring on ${clusterName}"
                runOnce="false"
            fi
            key="${pubIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting cassandra node at: ${ip}"
            start_dse_app ${key} ${ip} "cassandra"
        fi
    done

    runOnce="true"
    for ip in "${!cluster_pubIp_application[@]}"; do
        if [[ "${cluster_pubIp_application[${ip}]}" == "spark" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting analytics ring on ${clusterName}"
                runOnce="false"
            fi
            key="${pubIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting spark node at: ${ip}"
            start_dse_app ${key} ${ip} "spark"
        fi
    done

    runOnce="true"
    for ip in "${!cluster_pubIp_application[@]}"; do
        if [[ "${cluster_pubIp_application[${ip}]}" == "solr" ]]; then
            if [ "${runOnce}" == "true" ]; then
                echo ""
                echo "---------------------------------------------------"
                echo "${LOGO}-INFO: starting solr ring on ${clusterName}"
                runOnce="false"
            fi
            key="${pubIps_keys[${ip}]}"
            echo "${LOGO}-INFO: starting solr node at: ${ip}"
            start_dse_app ${key} ${ip} "solr"

        fi
    done
fi

echo ""
echo "---------------------------------------------------"
echo "${LOGO}-INFO: clusterName ${clusterName} has been configured and started"
echo "${LOGO}-INFO: run 'nodetool status' on any node to see clusterName rings"
echo "${LOGO}-INFO: for spark console visit http://spark_master_ip:7080"
echo "${LOGO}-INFO: add ${clusterName} to opscenter by pasting these ips in the req'd box:"
for ip in "${!prvIps_cluster[@]}"; do
    if [[ "${prvIps_cluster[${ip}]}" == "${clusterName}" ]]; then
        echo "${ip}"
    fi
done
echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
exit -1
}


#************************************input-checker

function check_build_dse_input(){

if [ "$1" == "number_of_servers" ]; then
    while ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 0 -o "$user_choice" -gt 8 ]; do
        echo "...invalid choice - enter a number between 0 and 8"
        read user_choice
    done
else
    while ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 0 -o "$user_choice" -gt "$(($loopcount-1))" ]; do
        echo "...invalid choice - choose number in range"
        read user_choice
    done
fi
}
