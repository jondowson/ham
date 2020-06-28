#!/usr/local/bin/bash

# script_name: start_app_instance_dse.sh
# author: jd
# about: restart a datastax cluster/ring application and awaken from sleep if req'd


start_app_cluster(){

# incoming variables:
# ${1} menu name

# format output
menu_check "top" ${1}

# steps to start a dse cluster:
# 1) cluster_choice_start:       choose dse cluster to revive
# 2) ring_types_start:           get available rings for this cluster to choose from
# 4) cluster_ring_start_app:     start the dse service on each ring node gracefully

# declare arrays required across functions in this script:
#   associative array set in ring_types_start() function
#   req'd also in ring_choice_start() function
declare -a ring_types=()

# call functions in this order:
cluster_choice_start
ring_types_start
cluster_ring_start_app "cluster"

# format output:
menu_check "bottom" ${1}
}

start_app_ring(){

# incoming variables:
# ${1} menu name

# format output
menu_check "top" ${1}

# steps to start a dse cluster ring
# 1) cluster_choice_start:       choose dse cluster to revive
# 2) ring_types_start:           get available rings for this cluster to choose from
# 3) ring_choice_start:          choose ring to restart
# 4) cluster_ring_start_app:     start the dse service on each ring node gracefully

# call functions in this order
cluster_choice_start
ring_types_start
ring_choice_start
cluster_ring_start_app "ring"

# format output
menu_check "bottom" ${1}
}


#(1)*********************************cluster_choice

function cluster_choice_start(){

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
echo ">>>>>>>>>>>>>>> which-cluster-to-restart-nodes-?"
echo ""
echo "n.b.: any instances in a stopped state will be awoken !!"
echo "n.b.: nodes already running will have dse restarted !!"
echo ""
loopcount=1
for name in "${unique_cluster_names[@]}"; do
    # in this case we do not wat to display these two as options
        echo "${loopcount}) ${name}"
        let loopcount=loopcount+1
done
read user_choice
check_input "cluster"
clusterName=${unique_cluster_names[$((${user_choice}))]}
}


#(2)*********************************ring_types

function ring_types_start(){

cassFlag="false"
sparkFlag="false"
solrFlag="false"

# for this cluster find rings in use
for ip in "${!prvIps_cluster[@]}"; do
    if [ "${prvIps_cluster[${ip}]}" == "${clusterName}" ];then
        if [ "${ips_applications[${ip}]}" == "cassandra" ] && [ "${cassFlag}" == "false" ];then
            ring_types+=('cassandra')
            cassFlag="true"
        elif [ "${ips_applications[${ip}]}" == "spark" ] && [ "${sparkFlag}" == "false" ];then
            ring_types+=('spark')
            sparkFlag="true"
        elif [ "${ips_applications[${ip}]}" == "solr" ] && [ "${solrFlag}" == "false" ];then
            ring_types+=('solr')
            solrFlag="true"
        fi
    fi
done
}


#(3)*********************************ring_choice

function ring_choice_start(){

echo ""
echo ">>>>>>>>>>>>>>> which-ring-type-to-restart-?"
echo ""
echo "n.b.: cluster ${clusterName} has these rings:"
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
else
    solrFlag="true"
fi
}


#(4)*********************************cluster_ring_start_app

function cluster_ring_start_app(){

declare -A prvIp_ringCassAsleep=()
declare -A prvIp_ringSparkAsleep=()
declare -A prvIp_ringSolrAsleep=()

letsPause="false"
# awaken any stopped instances for this cluster
for ip in "${!prvIps_clusters_stopped[@]}"; do
    if [ "${prvIps_clusters_stopped[${ip}]}" == "${clusterName}" ];then
        instanceId=${ips_instanceIds[${ip}]}
        serverName=${ips_names[${ip}]}
        application=${ips_applications[${ip}]}

        # it is possible that not all the nodes in a ring are stopped
        # for each ring type get the ips of the stopped nodes
        if [ "${application}" == "cassandra" ]; then
            prvIp_ringCassAsleep[${ip}]=${application}
        elif [ "${application}" == "spark" ]; then
            prvIp_ringSparkAsleep[${ip}]=${application}
        elif [ "${application}" == "solr" ]; then
            prvIp_ringSolrAsleep[${ip}]=${application}
        else
            echo "${LOGO}-INFO: no such type of datastax ring - now exiting ham"
            exit -1
        fi
        start_instance ${instanceId} ${serverName}
        letsPause="true"
    fi
done

# if at least one instance was awoken
if [ "${letsPause}" == "true" ]; then
    timecount "${AWAKEN}" "${LOGO}-INFO: ${AWAKEN} second pause to awaken instance(s) from sleep state"
    # refresh local list of instances
    echo "${LOGO}-INFO: refreshing ham tables and arrays"
    tables_refresh
    source ${TABLES}tables_arrays.sh
fi

# start cassandra nodes
nodeType="cassandra"
if [ ${cassFlag} == "true" ]; then
    # start cassandra ring
    for ip in "${!cassandra_prvIps_cluster[@]}"; do
        if [ "${cassandra_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            if [ "${MODE}" == "local" ]; then
                modeIp=${prvIps_pubIps[${ip}]}
                pubIp=${prvIps_pubIps[${ip}]}
            else
                modeIp=${ip}
                pubIp=${prvIps_pubIps[${ip}]}
            fi
            key="${ips_keys[${ip}]}"
            # check if any nodes for this ring type are stopped
            if [ ${#prvIp_ringCassAsleep[@]} -ne 0 ]; then
                # awaken the nodes, re-assign the new public ip and start the dse service
                if [ "${prvIp_ringCassAsleep[${ip}]}" == "cassandra" ]; then
                    start_dse_sleep ${key} ${modeIp} ${nodeType} ${pubIp}
                fi
            else
                # node was not in stopped state - restart dse service
                start_dse_app ${key} ${modeIp} ${nodeType}
            fi
        fi
    done
fi

# start spark nodes
nodeType="spark"
if [ ${cassFlag} == "true" ]; then
    # start spark ring
    for ip in "${!spark_prvIps_cluster[@]}"; do
        if [ "${spark_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            if [ "${MODE}" == "local" ]; then
                modeIp=${prvIps_pubIps[${ip}]}
                pubIp=${prvIps_pubIps[${ip}]}
            else
                modeIp=${ip}
                pubIp=${prvIps_pubIps[${ip}]}
            fi
            key="${ips_keys[${ip}]}"
            if [ ${#prvIp_ringCassAsleep[@]} -ne 0 ]; then
                if [ "${prvIp_ringSparkAsleep[${ip}]}" == "spark" ]; then
                    start_dse_sleep ${key} ${modeIp} ${nodeType} ${pubIp}
                fi
            else
                start_dse_app ${key} ${modeIp} ${nodeType}
            fi
        fi
    done
fi

# start solr nodes
nodeType="solr"
if [ ${cassFlag} == "true" ]; then
    # start solr ring
    for ip in "${!solr_prvIps_cluster[@]}"; do
        if [ "${solr_prvIps_cluster[${ip}]}" == "${clusterName}" ];then
            if [ "${MODE}" == "local" ]; then
                modeIp=${prvIps_pubIps[${ip}]}
                pubIp=${prvIps_pubIps[${ip}]}
            else
                modeIp=${ip}
                pubIp=${prvIps_pubIps[${ip}]}
            fi
            key="${ips_keys[${ip}]}"
            if [ ${#prvIp_ringCassAsleep[@]} -ne 0 ]; then
                if [ "${prvIp_ringSolrAsleep[${ip}]}" == "solr" ]; then
                    start_dse_sleep ${key} ${modeIp} ${nodeType} ${pubIp}
                fi
            else
                start_dse_app ${key} ${modeIp} ${nodeType}
            fi
        fi
    done
fi

if [ "${1}" == "ring" ]; then
    echo ""
    echo "-------------------------------------------"
    echo "${LOGO}-INFO: ring ${ringType} on cluster ${clusterName} has been restarted"
    echo "${LOGO}-INFO: confirm restart with opscenter or enter 'nodetool status' on any ${clusterName} node"
    if [ "${ringType}" == "spark" ]; then
        echo "${LOGO}-INFO: for spark console visit http://spark_master_ip:7080"
    fi
    echo "${LOGO}-INFO: now exiting - rerun ham to update menus"
    exit -1

elif [ "${1}" == "cluster" ]; then
    echo ""
    echo "-------------------------------------------"
    echo "${LOGO}-INFO: dse nodes for cluster ${clusterName} have been restarted"
    echo "${LOGO}-INFO: confirm restart with opscenter or enter 'nodetool status' on any ${clusterName} node"
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
