#!/bin/bash

declare -a IPS=($ANSIBLE_HOST_IP)
CONFIG_FILE=hosts.yaml python3 inventory.py ${IPS[@]}
ansible-playbook -i hosts.yaml --become --become --become-user=root cluster.yml

# Call copy_k8s_config here???

sshpass -p $ANSIBLE_PASSWORD scp -o StrictHostKeyChecking=no -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/kubeconfig
sed -i 's/127.0.0.1/$ANSIBLE_HOST_IP/g' "${PROJECT_ROOT}"/kubeconfig



copy_k8s_config() {
# TODO Use Kubespray variables in BMRA to simplify this
    MASTER_IP=$(get_host_pxe_ip "nodes[0]")
    # shellcheck disable=SC2087
    ssh -o StrictHostKeyChecking=no -tT "$USERNAME"@"$(get_vm_ip)" << EOF
scp -o StrictHostKeyChecking=no -q root@"$MASTER_IP":/root/.kube/config "${PROJECT_ROOT}"/kubeconfig
sed -i 's/127.0.0.1/$MASTER_IP/g' "${PROJECT_ROOT}"/kubeconfig
EOF

# Copy kubeconfig from Jump VM to appropriate location in Jump Host
# Direct scp to the specified location doesn't work due to permission/ssh-keys
    scp  -o StrictHostKeyChecking=no "$USERNAME"@"$(get_vm_ip)":"${PROJECT_ROOT}"/kubeconfig kubeconfig
    if [ -d "/home/opnfv/functest-kubernetes" ]; then
        sudo cp kubeconfig /home/opnfv/functest-kubernetes/config
    fi
}
