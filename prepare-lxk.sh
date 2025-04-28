#!/bin/bash

sudo virsh start master
sudo virsh start node1
sudo virsh start node2
sleep 60
ssh-keygen -q -t rsa -N '' -f /home/$USER/.ssh/id_rsa
sshpass -p "altkom" ssh-copy-id -o StrictHostKeyChecking=no student@master
sshpass -p "altkom" ssh-copy-id -o StrictHostKeyChecking=no student@node1
sshpass -p "altkom" ssh-copy-id -o StrictHostKeyChecking=no student@node2

for i in master; do ssh student@$i "sudo -S apt-get remove kubelet kubeadm kubectl docker.io -y; sudo rm /etc/apt/sources.list.d/kubernetes.list; sudo rm -rf /home/student/.kube; sudo kubeadm reset -f"; done 
for i in node1 node2; do ssh student@$i "sudo -S apt-get remove docker.io -y; sudo kubeadm reset -f; sudo rm /etc/apt/sources.list.d/kubernetes.list"; done
