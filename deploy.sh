#!/bin/bash

# check and install ansible
which ansible-playbook
if [ $? -ne 0 ]; then
    echo "try to install ansible"
    yum install -y epel-release
    yum install -y ansible
    if [ $? -ne 0 ]; then
        echo "ansible installation failure"
        exit 1
    fi
fi

# deploy ELK
ansible-playbook deploy.yml
