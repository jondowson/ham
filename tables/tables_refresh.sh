#!/usr/local/bin/bash

# script_name: tables_refresh.sh
# author: jd
# about: call aws account to get latest info about instances etc

# aws calls to download latest information about account
# use '&' to run in parallel and 'wait' to pause until all have finished

function tables_refresh(){

instances_text &
images_text &
subnets_text &
vpcs_text &
secgroups_text &
keypairs_text &
wait
}
