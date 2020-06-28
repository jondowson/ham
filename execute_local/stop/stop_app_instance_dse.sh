#!/usr/local/bin/bash

# script_name: stop_app_instance_dse.sh
# author: jd
# about: read in user options to stop for a given cluster one type of ring or all nodes in a cluster

stop_app_ring(){

# incoming variables:
# 1) ${1} menu name
# 2) ${2} sleep instance flag

# format output
menu_check "top" ${1}

# steps to stop a dse cluster ring:
# 1) cluster_choice:    choose dse cluster
# 2) ring_types:        discover what rings this cluster has
# 3) ring_choice:       choose cluster ring type to stop
# 4) ring_stop:         drain and stop the nodes on the ring

# declare arrays required across functions in this script:
#   associative array set in ring_types_stop() function
#   req'd also in ring_choice_stop() function
declare -a ring_types=()

sleepInstance=${2}

# call functions in this order:
cluster_choice_stop
ring_types_stop
ring_choice_stop
cluster_ring_stop "ring"

# format output:
menu_check "bottom" ${1}
}


stop_app_cluster(){

# incoming variables:
# 1) ${1} menu name
# 2) ${2} sleep instance flag

# format output
menu_check "top" ${1}

# steps to stop a dse cluster
# 1) cluster_choice:    choose dse cluster
# 2) ring_types:        discover what rings this cluster has
# 4) cluster_stop:      drain and stop all nodes on all rings in the cluster

sleepInstance=${2}

# call functions in this order
cluster_choice_stop
ring_types_stop
cluster_ring_stop "cluster"

# format output
menu_check "bottom" ${1}
}


#(1)*********************************cluster_choice

function cluster_choice_stop(){

# array to include these two reserved words
declare -a unique_cluster_names=('None' 'undefined')

# remove duplicate candidates
for ip in "${!ips_clusters[@]}"; do
    ucn_count=0
    for name in "${!unique_cluster_names[@]}"; do
        if [ "${ips_clusters[${ip}]}" == "${unique_cluster_names[${name}]}" ];then
            break
        else
            let ucn_count=ucn_count+1
        fi
        ucn_size=${#unique_cluster_names[@]}
        if [ "$ucn_count" == "${ucn_size}" ]; then
            unique_cluster_names[${ucn_size}+1]=${ips_clusters[${ip}]}
        fi
    done
done

# display cluster names - no duplicates
echo ""
echo ">>>>>>>>>>>>>>> which-cluster-to-stop-?"
echo ""
loopcount=1
for name in "${unique_cluster_names[@]}"; do
    echo "${loopcount}) ${name}"
    let loopcount=loopcount+1
done

read user_choice
check_input "cluster"
clusterName=${unique_cluster_names[$((${user_choice}))]}
}


#(2)*********************************ring_types

function ring_types_stop(){

cassFlag="false"
sparkFlag="false"
solrFlag="false"
# for this cluster find rings in use that are in a running state
for ip in "${!ips_clusters_running[@]}"; do
    if [ "${ips_clusters_running[${ip}]}" == "${clusterName}" ];then
        if [ "${ips_applications_running[${ip}]}" == "cassandra" ] && [ "${cassFlag}" == "false" ];then
            ring_types+=('cassandra')
            cassFlag="true"
        elif [ "${ips_applications_running[${ip}]}" == "spark" ] && [ "${sparkFlag}" == "false" ];then
            ring_types+=('spark')
            sparkFlag="true"
        elif [ "${ips_applications_running[${ip}]}" == "solr" ] && [ "${solrFlag}" == "false" ];then
            ring_types+=('solr')
            solrFlag="true"
        fi
    fi
done
}


#(3)*********************************ring_choice

function ring_choice_stop(){

echo ""
echo ">>>>>>>>>>>>>>> which-ring-type-to-stop-?"
if [ ${#ring_types[@]} -eq 0 ]; then
    echo ""
    echo "No dse rings on servers in a running state - exiting ham !!"
    echo ""
    exit -1
fi
echo ""
echo "n.b.: cluster ${clusterName} has these rings in a running state:"
echo ""

loopcount=1
for ring in "${ring_types[@]}"; do
    echo "${loopcount}) ${ring}"
    let loopcount=loopcount+1
done

read user_choice
check_input "ring"
ringType=${ring_types[$((${user_choice}-1))]}

cassFlag="false"
sparkFlag="false"
solrFlag="false"

if [ "${ringType}" == "cassandra" ]; then
    cassFlag="true"
elif [ "${ringType}" == "spark" ]; then
    sparkFlag="true"
elif [ "${ringType}" == "solr" ]; then
    solrFlag="true"
else
    echo "no such dse ring !!"
fi
}


#(4)*********************************cluster_ring_stop

function cluster_ring_stop(){

# stop cassandra nodes
nodeType="cassandra"
if [ ${cassFlag} == "true" ]; then
    # stop cassandra ring
    for ip in "${!cassandra_prvIps_cluster[@]}"; do
        if [ "${cassandra_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            key="${ips_keys[${ip}]}"
            hostname=${ip}
            serverIp=${ip}
            if [ "${MODE}" == "local" ]; then
                serverIp=${prvIps_pubIps[${ip}]}
            fi
            echo ""
            if [ "${sleepInstance}" == "true" ]; then
                stop_dse_sleep ${key} ${serverIp} ${hostname} "cassandra"
            else
                stop_dse_app ${key} ${serverIp} ${hostname} "cassandra"
            fi
            # also stop the instance if passed flag is 'true'
            if [ "${sleepInstance}" == "true" ]; then
                instanceId=${ips_instanceIds[${ip}]}
                serverName=${ips_names[${ip}]}
                stop_instance ${instanceId} ${serverName}
            fi
        fi
    done
fi
            
# stop spark nodes
nodeType="spark"
if [ ${sparkFlag} == "true" ]; then
    # stop spark ring
    for ip in "${!spark_prvIps_cluster[@]}"; do
        if [ "${spark_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            key="${ips_keys[${ip}]}"
            hostname=${ip}
            serverIp=${ip}
            if [ "${MODE}" == "local" ]; then
                serverIp=${prvIps_pubIps[${ip}]}
            fi
            echo ""
            if [ "${sleepInstance}" == "true" ]; then
                stop_dse_sleep ${key} ${serverIp} ${hostname} "cassandra"
            else
                stop_dse_app ${key} ${serverIp} ${hostname} "cassandra"
            fi
            # also stop the instance if passed flag is 'true'
            if [ "${sleepInstance}" == "true" ]; then
                instanceId=${ips_instanceIds[${ip}]}
                serverName=${ips_names[${ip}]}
                stop_instance ${instanceId} ${serverName}
            fi
        fi
    done
fi

# stop solr nodes
nodeType="solr"
if [ ${solrFlag} == "true" ]; then
    # stop solr ring
    for ip in "${!solr_prvIps_cluster[@]}"; do
        if [ "${solr_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            key="${ips_keys[${ip}]}"
            hostname=${ip}
            serverIp=${ip}
            if [ "${MODE}" == "local" ]; then
                serverIp=${prvIps_pubIps[${ip}]}
            fi
            echo ""
            if [ "${sleepInstance}" == "true" ]; then
                stop_dse_sleep ${key} ${serverIp} ${hostname} "cassandra"
            else
                stop_dse_app ${key} ${serverIp} ${hostname} "cassandra"
            fi
            # also stop the instance if passed flag is 'true'
            if [ "${sleepInstance}" == "true" ]; then
                instanceId=${ips_instanceIds[${ip}]}
                serverName=${ips_names[${ip}]}
                stop_instance ${instanceId} ${serverName}
            fi
        fi
    done
fi

if [ "${1}" == "ring" ]; then
    echo ""
    echo "-------------------------------------------"
    echo "${LOGO}-INFO: ring ${ringType} on cluster ${clusterName} has been drained and stopped"
    echo "${LOGO}-INFO: verify with opscenter or run 'nodetool status' on any cluster node"
    if [ "${ringType}" == "spark" ]; then
        echo "${LOGO}-INFO: for spark console visit http://spark_master_ip:7080"
    fi
    if [ "${sleepInstance}" == "true" ]; then
        echo "${LOGO}-INFO: the server with ring ${ringType} on cluster ${clusterName}'s is now in a stopped 'state'"
        echo "${LOGO}-INFO: verify with AWS console and check the 'state' of ${clusterName} instances"
    fi
    echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
    exit -1
elif [ "${1}" == "cluster" ]; then
    echo ""
    echo "-------------------------------------------"
    if [ "${sleepInstance}" == "true" ]; then
        echo "${LOGO}-INFO: all dse nodes for cluster ${clusterName} have been drained and stopped"
        echo "${LOGO}-INFO: cluster ${clusterName} instances are now in a stopped state"
        echo "${LOGO}-INFO: to verify login to AWS console and check the 'state' of ${clusterName} instances"
    elif [ "${sleepInstance}" == "false" ]; then
        echo "${LOGO}-INFO: all dse nodes for cluster ${clusterName} have been drained and stopped"
        echo "${LOGO}-INFO: to verify use opscenter or run 'nodetool status' on any cluster node"
    fi
    echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
    exit -1
fi
}


#************************************input-checker

function check_input(){

if [ "$1" == "number_of_servers" ]; then
    while ! [[ "${user_choice}" =~ ^[0-9]+$ ]] || [ "${user_choice}" -lt 0 -o "${user_choice}" -gt 8 ]; do
        echo "...invalid choice - enter a number between 0 and 8"
        read user_choice
    done
else
    while ! [[ "${user_choice}" =~ ^[0-9]+$ ]] || [ "${user_choice}" -lt 0 -o "${user_choice}" -gt "$(($loopcount-1))" ]; do
        echo "...invalid choice - choose number in range"
        read user_choice
    done
fi
}
