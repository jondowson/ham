#!/usr/local/bin/bash

# script_name: tables_arrays.sh
# author: jd
# about: define and populate arrays drawn from the tables and used throughout ham

#-------------------------------------------------------arrays-by-server-application-type

# each amazon server has a application tag and this identifies the applications running on it
# below are pairs of associative arrays for each server type as defined in the application tag field on the Amazon UI
# they capture the information required to connect to them - namely the public/private ips and security key
# ham can then connect to any server by its application and fire appropriate commands (e.g.stop/start/configure)

# as we are running this as a script and not calling it as a function...
# ... we need to include the main config file
source ${HAM_HOME}/admin/ham_config.sh

declare -A cassandra_pubIps_keys
declare -A cassandra_prvIps_keys
#2: dse spark
declare -A spark_pubIps_keys
declare -A spark_prvIps_keys
#3: dse solr
declare -A solr_pubIps_keys
declare -A solr_prvIps_keys
#4: mysql
declare -A mysql_pubIps_keys
declare -A mysql_prvIps_keys
#5: nginx-lb: load balancer
declare -A nginxlb_pubIps_keys
declare -A nginxlb_prvIps_keys
#6: nginx-a42-aml: nginx web server serving a42-aml application
declare -A nginxa42aml_pubIps_keys
declare -A nginxa42aml_prvIps_keys

# order of tab seperated values read in from admin/tables/instances.txt:
# 0-name|1-client|2-cluster|3-creator|4-application|5-pubIp|6-prvIp|7-key|8-vpc|9-state|10-region|11-size
# add an entry for each application type you want to control

while IFS=$'\t' read -r -a myArray
    do
        if [ "${myArray[4]}" == "cassandra" ]; then
            cassandra_pubIps_keys[${myArray[5]}]=${myArray[7]}
            cassandra_prvIps_keys[${myArray[6]}]=${myArray[7]}
        elif [ "${myArray[4]}" == "spark" ]; then
            spark_pubIps_keys[${myArray[5]}]=${myArray[7]}
            spark_prvIps_keys[${myArray[6]}]=${myArray[7]}
        elif [ "${myArray[4]}" == "solr" ]; then
            solr_pubIps_keys[${myArray[5]}]=${myArray[7]}
            solr_prvIps_keys[${myArray[6]}]=${myArray[7]}
        elif [ "${myArray[4]}" == "mysql" ]; then
            mysql_pubIps_keys[${myArray[5]}]=${myArray[7]}
            mysql_prvIps_keys[${myArray[6]}]=${myArray[7]}
        elif [ "${myArray[4]}" == "nginx-lb" ]; then
            nginxlb_pubIps_keys[${myArray[5]}]=${myArray[7]}
            nginxlb_prvIps_keys[${myArray[6]}]=${myArray[7]}
         elif [ "${myArray[4]}" == "nginx-a42-aml" ]; then
            nginxa42aml_pubIps_keys[${myArray[5]}]=${myArray[7]}
            nginxa42aml_prvIps_keys[${myArray[6]}]=${myArray[7]}
        fi
    done < ${TABLES}instances.txt

#-------------------------------------------------------arrays-for-all-server

# public/private ips with attribute for all servers
declare -A pubIps_name
declare -A prvIps_name
declare -A pubIps_cluster
declare -A prvIps_cluster
declare -A pubIps_application
declare -A prvIps_application
declare -A pubIps_keys
declare -A prvIps_keys
declare -A pubIps_instanceId
declare -A prvIps_instanceId
declare -A pubIps_prvIps
declare -A prvIps_pubIps

# all ips with attribute
declare -A ips_names
declare -A ips_clusters
declare -A ips_applications
declare -A ips_keys
declare -A ips_instanceIds
declare -A ips_state

declare -A prvIps_clusters_stopped
declare -A ips_clusters_stopped

declare -A  prvIps_clusters_running
declare -A  ips_clusters_running
declare -A  ips_applications_running
declare -A  instanceId_name
declare -A  instanceId_pubIps
declare -A  instanceId_prvIps

# order of tab seperated values read in from admin/tables/instances.txt:
# 0-name|1-client|2-cluster|3-creator|4-application|5-pubIp|6-prvIp|7-key|8-vpc|9-state|10-region|11-size|12-instanceId
while IFS=$'\t' read -r -a myArray
do
    if [ "${myArray[9]}" != "terminated" ]; then

        # segregated by public or private ips
        pubIps_name[${myArray[5]}]=${myArray[0]}
        prvIps_name[${myArray[6]}]=${myArray[0]}
        pubIps_cluster[${myArray[5]}]=${myArray[2]}
        prvIps_cluster[${myArray[6]}]=${myArray[2]}
        pubIps_application[${myArray[5]}]=${myArray[4]}
        prvIps_application[${myArray[6]}]=${myArray[4]}
        pubIps_keys[${myArray[5]}]=${myArray[7]}
        prvIps_keys[${myArray[6]}]=${myArray[7]}
        pubIps_instanceId[${myArray[5]}]=${myArray[12]}
        prvIps_instanceId[${myArray[6]}]=${myArray[12]}
        instanceId_pubIps[${myArray[12]}]=${myArray[5]}
        instanceId_prvIps[${myArray[12]}]=${myArray[6]}

        # get private from public ip and vice-versa
        pubIps_prvIps[${myArray[5]}]=${myArray[6]}
        prvIps_pubIps[${myArray[6]}]=${myArray[5]}

        # all ips regardless - why not !?!
        ips_names[${myArray[5]}]=${myArray[0]}
        ips_names[${myArray[6]}]=${myArray[0]}
        ips_clusters[${myArray[5]}]=${myArray[2]}
        ips_clusters[${myArray[6]}]=${myArray[2]}
        ips_applications[${myArray[5]}]=${myArray[4]}
        ips_applications[${myArray[6]}]=${myArray[4]}
        ips_keys[${myArray[5]}]=${myArray[7]}
        ips_keys[${myArray[6]}]=${myArray[7]}
        ips_instanceIds[${myArray[5]}]=${myArray[12]}
        ips_instanceIds[${myArray[6]}]=${myArray[12]}
        ips_state[${myArray[5]}]=${myArray[9]}
        ips_state[${myArray[6]}]=${myArray[9]}
        instanceId_name[${myArray[12]}]=${myArray[0]}

        # handy for establishing when instances are in a stopped state
        if [ "${myArray[9]}" == "stopped" ]; then
            prvIps_clusters_stopped[${myArray[6]}]=${myArray[2]}
            ips_clusters_stopped[${myArray[5]}]=${myArray[2]}
            ips_clusters_stopped[${myArray[6]}]=${myArray[2]}
        fi

        # handy for establishing when instances are in a running state
        if [ "${myArray[9]}" == "running" ]; then
            prvIps_clusters_running[${myArray[6]}]=${myArray[2]}
            ips_clusters_running[${myArray[5]}]=${myArray[2]}
            ips_clusters_running[${myArray[6]}]=${myArray[2]}
            ips_applications_running[${myArray[5]}]=${myArray[4]}
            ips_applications_running[${myArray[6]}]=${myArray[4]}
        fi

    fi
done < ${TABLES}instances.txt

#-------------------------------------------------------arrays-build-servers-and-clusters

# these associative arrays are used when building servers / dse clusters from amazon machine images
# they help ensure servers are built from the desired image into the desired vpc and subnet

# associative arrays for building servers
declare -A vpcid_vpcname
declare -A secgroupid_vpcid
declare -A secgroupid_groupname
declare -A subnetid_vpcid
declare -A subnetid_region
declare -A amiId_amiName

# reads from files in /admin/tables
while IFS=$'\t' read -r -a myArray
    do
        vpcid_vpcname[${myArray[1]}]=${myArray[0]}
    done < ${TABLES}vpcs.txt

while IFS=$'\t' read -r -a myArray
    do
        secgroupid_vpcid[${myArray[0]}]=${myArray[2]}
        secgroupid_groupname[${myArray[0]}]=${myArray[1]}
    done < ${TABLES}secgroups.txt

while IFS=$'\t' read -r -a myArray
    do
        subnetid_vpcid[${myArray[1]}]=${myArray[2]}
        subnetid_region[${myArray[1]}]=${myArray[0]}
    done < ${TABLES}subnets.txt

while IFS=$'\t' read -r -a myArray
    do
        amiId_amiName[${myArray[0]}]=${myArray[1]}
    done < ${TABLES}images.txt

#---------------------------------------------------------------------------AWS-arrays-build-clusters

# these arrays are used when creating datastax clusters
# dse nodes can either be cassandra, solr or spark
# during the cluster config process, once the servers have been built...
# ...these arrays are used to map correct actions to node type

# associative arrays for building clusters
declare -A spark_pubIps_cluster
declare -A spark_prvIps_cluster
declare -A solr_pubIps_cluster
declare -A solr_prvIps_cluster
declare -A cassandra_pubIps_cluster
declare -A cassandra_prvIps_cluster

# order of tab seperated values read in from admin/tables/instances.txt:
# 0-name|1-client|2-cluster|3-creator|4-application|5-pubIp|6-prvIp|7-key|8-vpc|9-state|10-region|11-size

while IFS=$'\t' read -r -a myArray
    do
        if [ "${myArray[4]}" == "spark" ] && [ "${myArray[9]}" != "terminated" ]; then
                spark_pubIps_cluster[${myArray[5]}]=${myArray[2]}
                spark_prvIps_cluster[${myArray[6]}]=${myArray[2]}

        elif [ "${myArray[4]}" == "solr" ] && [ "${myArray[9]}" != "terminated" ]; then
                solr_pubIps_cluster[${myArray[5]}]=${myArray[2]}
                solr_prvIps_cluster[${myArray[6]}]=${myArray[2]}

        elif [ "${myArray[4]}" == "cassandra" ] && [ "${myArray[9]}" != "terminated" ]; then
                cassandra_pubIps_cluster[${myArray[5]}]=${myArray[2]}
                cassandra_prvIps_cluster[${myArray[6]}]=${myArray[2]}
        fi
    done < ${TABLES}instances.txt
