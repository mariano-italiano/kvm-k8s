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
fi
