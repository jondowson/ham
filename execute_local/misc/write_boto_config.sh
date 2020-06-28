#!/usr/local/bin/bash

# script_name: write_boto_config.sh
# author: jd
# about: writes dynamic boto credentials file
# notes: boto is an add on to aws cli tools

boto_config_file=${USER_HOME}/.boto

# delete any existing dynamically generated file for this menu
rm -f ${boto_config_file}

echo "[Credentials]" >> ${boto_config_file}
echo "aws_access_key_id=${AWS_ACCESS_KEY}" >> ${boto_config_file}
echo "aws_secret_access_key=${AWS_SECRET_KEY}" >> ${boto_config_file}
