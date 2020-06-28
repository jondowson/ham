#!/usr/bin/python

# script_name: secgroup_status.py
# author: jd
# about: gets all security groups for an account in a region and lists open ports

import boto.ec2
conn = boto.ec2.connect_to_region("eu-west-1")
groups = conn.get_all_security_groups()
for group in groups:
    print ""
    print "==============================================="
    print "Security Group Name: ", group.name
    print "IP Protocol | From Port | To Port | Rule Grants"
    print "-----------------------------------------------"
    for rule in group.rules:
        print rule.ip_protocol, "       ", rule.from_port, "       ", rule.to_port, "       ", rule.grants
        print "-----------------------------------------------"
