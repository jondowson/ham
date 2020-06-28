#!/usr/local/bin/bash

# script_name: build_calls.sh
# author: jd
# about: call amazon account to create a new server

function instances_build(){

# 9 variables have been passed in this order
# 1-amiId|2-howMany|3-serverType|4-serverKey|5-secgroupId|6-subnetId|7-server_name|8-nodeType|9-clusterName

aws ec2 run-instances --image-id ${1} --count ${2} --instance-type ${3} --key-name ${4} \
    --security-group-ids ${5} --subnet-id ${6} --output text > ${TABLES}newInstance_id.txt --query \
     'Instances[*].{InstanceId:InstanceId}'

# add a pause to allow instances to config
timecount "10" "${LOGO}-INFO: 10 second pause to allow new server to register"

# capture aws response that includes the new instance id
# this is subsequently used to add name and creator tags
file=${TABLES}newInstance_id.txt

# make everyones initials appear capatalised in the intitials column on the aws console
USER_CAPATALISED=$(echo "${USER_INITIALS}" | tr '[:lower:]' '[:upper:]')

# check that file is not empty - should contain one line with new instance id
line=$(head -n 1 ${file})
if [ "${line}" == "" ]; then
    echo "${LOGO}-INFO: build_calls.sh - server creation has failed !!"
else
    while read line; do
        aws ec2 create-tags --resources ${line} --tags Key=Name,Value=${7} Key=Creator,Value=${USER_CAPATALISED} \
        Key=Application,Value=${8} Key=Cluster,Value=${9}

        echo "${LOGO}-INFO: server ${7} has been built"

        # enable termination protection
        aws ec2 modify-instance-attribute --instance-id ${line} --disable-api-termination
        echo "${LOGO}-INFO: server ${7} termination protection enabled"

        # get the public and private ip of the new instance and save to file
        aws ec2 describe-instances --instance-ids ${line} --output text > ${TABLES}newInstance_ips.txt \
        --query 'Reservations[*].Instances[*].[PublicIpAddress, PrivateIpAddress]'
    done < ${file}
fi

# tidy up
rm ${TABLES}newInstance_id.txt
}

#--------------------------------------------------------------------------AWS-CALLS-other

# enable automatic allocation of public ips for new servers in this vpc - needs to be run only once for any given vpc
function modify_subnet_attribute(){
aws ec2 modify-subnet-attribute --subnet-id ${1} --map-public-ip-on-launch
}
