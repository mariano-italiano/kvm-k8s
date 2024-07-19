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
        sudo apt install -y cpu-checker qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils vagrant git
        sudo systemctl enable --now libvirtd
        sudo usermod -aG kvm student
        sudo usermod -aG libvirt student
        vagrant plugin install vagrant-libvirt
        echo
        git clone https://github.com/mariano-italiano/kvm-k8s.git
        cd kvm-k8s/kubernetes/vagrant
        vagrant up --provider libvirt

        MASTER_IP=`virsh net-dhcp-leases vagrant-libvirt | grep master |awk '{print $5}'`
        WORKER1_IP=`virsh net-dhcp-leases vagrant-libvirt | grep worker1 |awk '{print $5}'`
        WORKER2_IP=`virsh net-dhcp-leases vagrant-libvirt | grep worker2 |awk '{print $5}'`
        
        echo 
        echo "---------------------------------------------------------"
        echo -e "\033[0;30m\033[107mKubernetes Infrastructure details                        \033[0m"
        echo "---------------------------------------------------------"
        echo -e " Control plane hostname:      \033[32mmaster\033[0m"
        echo -e " Control plane IP address:    \033[93m$MASTER_IP\033[0m"
        echo "---------------------------------------------------------"
        echo -e " Worker1 node hostname:       \033[32mworker1\033[0m"
        echo -e " Worker1 node IP address:     \033[93m$WORKER1_IP\033[0m"
        echo "---------------------------------------------------------"
        echo -e " Worker2 node hostname:       \033[32mworker2\033[0m"
        echo -e " Worker2 node IP address:     \033[93m$WORKER2_IP\033[0m"
        echo "---------------------------------------------------------"

fi
