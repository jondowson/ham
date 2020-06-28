#!/usr/local/bin/bash

# script_name: write_aws_config.sh
# author: jd
# about: writes dynamic aws credentials file

aws_config_file="${USER_HOME}"/.aws/config

# delete any existing dynamically generated file for this menu
rm -f "${aws_config_file}"

echo "[default]\n" >> "${aws_config_file}"
echo "aws_access_key_id = ${AWS_ACCESS_KEY}" >> "${aws_config_file}"
echo "aws_secret_access_key = ${AWS_SECRET_KEY}" >> "${aws_config_file}"
echo "region = ${AWS_DEFAULT_REGION}" >> "${aws_config_file}"
