#!/usr/local/bin/bash

# script_name: status_calls.sh
# author: jd
# about: calls to aws account using the aws cli toolkit
#        ... some are written to file and others to screen
#        ... a variant of which does not use menu_check function for formatting

#************************************calls-written-to-file

function instances_text(){
aws ec2 describe-instances --output text > ${TABLES}instances.txt\
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`] |[0].Value,Tags[?Key==`Client`] | [0].Value,Tags[?Key==`Cluster`] | [0].Value,Tags[?Key==`Creator`] | [0].Value,Tags[?Key==`Application`] | [0].Value, PublicIpAddress, PrivateIpAddress, KeyName, VpcId, State.Name, Placement.AvailabilityZone, InstanceType, InstanceId]'
}

function images_text() {
aws ec2 describe-images --output text > ${TABLES}images.txt --owner self\
    --query 'Images[*].{Name:Name,Id:ImageId}'
}

function keypairs_text(){
aws ec2 describe-key-pairs --output text > ${TABLES}keypairs.txt\
    --query 'KeyPairs[*].{KeyName:KeyName}'
}

function secgroups_text(){
aws ec2 describe-security-groups --output text > ${TABLES}secgroups.txt\
    --query 'SecurityGroups[*].{GroupId:GroupId, VpcId:VpcId,GroupName:GroupName}'
}

function vpcs_text(){
aws ec2 describe-vpcs --output text > ${TABLES}vpcs.txt\
    --query 'Vpcs[*].[Tags[?Key==`Name`] | [0].Value,VpcId]'
}

function subnets_text(){
aws ec2 describe-subnets --output text > ${TABLES}subnets.txt\
    --query 'Subnets[*].{SubnetId:SubnetId,VpcId:VpcId,AvailabilityZone:AvailabilityZone}'
}

#************************************calls-written-to-screen-with-formatting

function instances_status() {
menu_check "table-top" $1
echo ""
echo "column legend: 1-Name | 2-Type | 3-Public IP | 4-Private IP | 5-Pem Key | 6-VPC | 7-Status | 8-Region | 9-Size"
aws ec2 describe-instances --output table\
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`] | [0].Value, Tags[?Key==`Type`] | [0].Value,PublicIpAddress, PrivateIpAddress, KeyName, VpcId, State.Name, Placement.AvailabilityZone,InstanceType]'

echo ""
echo "column legend: 1-Public IP | 2-Private IP | 3-Security Group"
aws ec2 describe-instances --output table\
    --query 'Reservations[*].Instances[*].[[PublicIpAddress,PrivateIpAddress,SecurityGroups[].GroupName][]]'
menu_check "table-bottom" $1
}

function volumes_status() {
menu_check "table-top" $1

echo ""
echo "column legend: 1-Volume Name | 2-IOPS | 3-GB | 4-Region  | 5-Type |  6-Status   | 7-Attached-to | 8-mounted on |"
aws ec2 describe-volumes --output table\
    --query 'Volumes[*].[Tags[?Key==`Name`] | [0].Value,Iops, Size, AvailabilityZone, VolumeType, State,Attachments[0].InstanceId, Attachments[0].Device]'
menu_check "table-bottom" $1
}

function vpcs_status() {
menu_check "table-top" $1
echo ""
echo "column legend: 1-Name | 2-VpcId | 3-CidrBlock | 4-State"
aws ec2 describe-vpcs --output table --query 'Vpcs[*].[Tags[?Key==`Name`] | [0].Value, VpcId, CidrBlock, State]'
menu_check "table-bottom" $1
}

function secgroups_status() {
menu_check "table-top" $1
echo ""
aws ec2 describe-security-groups --output table\
    --query 'SecurityGroups[*].{GroupName:GroupName,Description:Description, GroupId:GroupId}'

python ${STATUS_REMOTE}secgroup_status.py
menu_check "table-bottom" $1
}

#************************************calls-written-to-screen-without-formatting

function instances_status_sendfile() {
echo ""
echo "column legend: 1-Name | 2-Type | 3-Public IP | 4-Private IP | 5-Pem Key | 6-VPC | 7-Status | 8-Region | 9-Size"
aws ec2 describe-instances --output table\
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`] | [0].Value,PublicIpAddress, PrivateIpAddress, KeyName]'
}
