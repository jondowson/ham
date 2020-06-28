#!/usr/local/bin/bash

# script_name: config_dse_node.sh
# author: jd
# about: configure a dse node on the fly !

#------------------------------------------------tasks-for-all-types-of-nodes

function config_dse_node(){

# The req'd variables are passed in this order:
# 1) the name of the pem key required to access this server.
# 2) ${prvIp} or ${pubIp} - public or private ip used to connect to server.
# 3) the cluster name.
# 4) node type - spark, solr or cassandra.
# 5) ${prvIp} - private ip associated with this server - always private ips for dse config scripts.
# 6) ${pubIp} - public ip required to config cassandra-env.sh
# 7) list of all private ips associated with this cluster as a comma separated string.

# assign cluster name
echo "${LOGO}-INFO: updating cassandra.yaml cluster name to: ${3}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i 's/cluster_name: '\''Test Cluster'\''/cluster_name: '\''${3}'\''/g' \
/etc/dse/cassandra/cassandra.yaml"; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

# re-assign listen address to the private ip address of this server
echo "${LOGO}-INFO: updating cassandra.yaml listen address to: ${5}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i 's/listen_address: localhost/listen_address: ${5}/g' \
/etc/dse/cassandra/cassandra.yaml"; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

# re-assign rpc address to the private ip address of this server
echo "${LOGO}-INFO: updating cassandra.yaml rpc address to: ${5}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i 's/rpc_address: localhost/rpc_address: ${5}/g' \
/etc/dse/cassandra/cassandra.yaml"; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

# add seeds - all cluster nodes irrespective of type - in the the same order for all nodes
echo "${LOGO}-INFO: updating cassandra.yaml seeds list to : ${7}"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i 's/- seeds: "\""127.0.0.1"\""/- seeds: "\""${7}"\""/g' \
/etc/dse/cassandra/cassandra.yaml"; do :; done > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

JVM="\$JVM_OPTS"
echo "${LOGO}-INFO: updating <public name> in cassandra-env.sh to: ${6}"
# assign the public ip of this server to address local access issues for shell connections
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo sed -i 's/# JVM_OPTS="\""${JVM} -Djava.rmi.server.hostname=<public name>"\""/JVM_OPTS="\""${JVM} \
-Djava.rmi.server.hostname=${6}"\""/g' /etc/dse/cassandra/cassandra-env.sh"; do :; done \
 >${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

# ensure dse service is not running
echo "${LOGO}-INFO: ensuring dse is stopped"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo service dse stop"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
timecount "10" "${LOGO}-INFO: allowing for dse to stop"

# clear any existing data from cassandra on this node
echo "${LOGO}-INFO: deleting any existing commitlog"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo rm -rf /var/lib/cassandra/commitlog"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: deleting any existing saved_caches"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo rm -rf /var/lib/cassandra/saved_caches"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

echo "${LOGO}-INFO: deleting any existing cassandra data"
until ssh -i ${KEYS}${1}.pem ubuntu@${2} -o StrictHostKeyChecking=no \
"sudo rm -rf /var/lib/cassandra/data"; do :; done \
> ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

#------------------------------------------------node-type-dependent-tasks

#----------------------------------non-solr-nodes

if [ "${4}" != "solr" ]; then
    echo "${LOGO}-INFO: enabling vnodes"
    # enable vnode token generation
    until ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no\
    "sudo sed -i 's/# num_tokens: 256/num_tokens: 256/g' /etc/dse/cassandra/cassandra.yaml"; do :; done \
    > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null

    # disable manual token generation
    ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no\
    "sudo sed -i 's/initial_token:/#initial_token:/g' /etc/dse/cassandra/cassandra.yaml" \
    > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
fi

#----------------------------------activate-spark-node
if [ "${4}" == "spark" ]; then
    echo "${LOGO}-INFO: setting server as a spark node"
    # change node type to spark
    ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no\
    "sudo sed -i 's/SPARK_ENABLED=0/SPARK_ENABLED=1/g' /etc/default/dse" \
    > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
fi
#----------------------------------activate-solr-node
if [ "${4}" == "solr" ]; then
    echo "${LOGO}-INFO: setting server as a solr node"
    # change node type to solr
    ssh -i ${KEYS}${1}.pem ubuntu@${2} -oStrictHostKeyChecking=no\
    "sudo sed -i 's/SOLR_ENABLED=0/SOLR_ENABLED=1/g' /etc/default/dse" \
    > ${LOGS}${LOGO}.out 2> ${LOGS}${LOGO}.err < /dev/null
fi

#----------------------------------activate-cassandra-node
# cassandra node is default so do nothing
}
