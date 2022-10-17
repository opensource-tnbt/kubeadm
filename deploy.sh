#!/bin/bash

declare -a IPS=($ANSIBLE_HOST_IP)
CONFIG_FILE=hosts.yaml python3 inventory.py ${IPS[@]}
ansible-playbook -i hosts.yaml --become --become --become-user=root cluster.yml

# Copy the kubeconfig 
sshpass -p $ANSIBLE_PASSWORD scp -o StrictHostKeyChecking=no -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/kubeconfig
sed -i 's/127.0.0.1/$ANSIBLE_HOST_IP/g' "${PROJECT_ROOT}"/kubeconfig
