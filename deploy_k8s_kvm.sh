#!/bin/bash
# Installation script for KVM K8s cluster
# Author: Marcin Kujawski
# Version: 1.0

VIRT_ON=`egrep -c '(vmx|svm)' /proc/cpuinfo`

if [ $VIRT_ON -eq 0 ] ; then
        echo
        echo "Virtualization is not enabled. Please turn on Virtualization and run script again."
        echo
else
        sudo apt update
        sudo apt install -y cpu-checker qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils sshpass vagrant git
        sudo systemctl enable --now libvirtd
        sudo usermod -aG kvm student
        sudo usermod -aG libvirt student
        vagrant plugin install vagrant-libvirt
        echo
        git clone https://github.com/mariano-italiano/kvm-k8s.git
        cd kubernetes/vagrant
        vagrant up --provider libvirt

        MASTER_CIDR=`virsh net-dhcp-leases vagrant-libvirt | grep master |awk '{print $5}'`
        WORKER1_CIDR=`virsh net-dhcp-leases vagrant-libvirt | grep worker1 |awk '{print $5}'`
        WORKER2_CIDR=`virsh net-dhcp-leases vagrant-libvirt | grep worker2 |awk '{print $5}'`

        echo
        echo "---------------------------------------------------------"
        echo -e "\033[0;30m\033[107mKubernetes Infrastructure details                       \033[0m"
        echo "---------------------------------------------------------"
        echo -e " Control plane hostname:      \033[32mmaster\033[0m"
        echo -e " Control plane IP address:    \033[93m$MASTER_CIDR\033[0m"
        echo "---------------------------------------------------------"
        echo -e " Worker1 node hostname:       \033[32mworker1\033[0m"
        echo -e " Worker1 node IP address:     \033[93m$WORKER1_CIDR\033[0m"
        echo "---------------------------------------------------------"
        echo -e " Worker2 node hostname:       \033[32mworker2\033[0m"
        echo -e " Worker2 node IP address:     \033[93m$WORKER2_CIDR\033[0m"
        echo "---------------------------------------------------------"

        MASTER_IP=`virsh net-dhcp-leases vagrant-libvirt | grep master |awk '{print $5}'| cut -d "/" -f1`
        sshpass -p "kubeadmin" ssh -o StrictHostKeyChecking=accept-new root@$MASTER_IP cp -rp /etc/kubernetes/admin.conf /root/.kube/config >/dev/null 2>&1

        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        mv ./kubectl /usr/local/bin/kubectl
        echo 'source <(kubectl completion bash)' >>~/.bashrc
        source ~/.bashrc
        mkdir -p ~/.kube
        sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$MASTER_IP:/etc/kubernetes/admin.conf ~/.kube/config
fi
