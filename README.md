# Setup K8s cluster with KVM

## Provisioning the Kubernetes cluster
### Clone the repo
```sh
$ git clone https://github.com/mariano-italiano/kvm-k8s.git
```

### Install 
```sh
$ cd kvm-k8s
$ source deploy_k8s_kvm.sh
```

### Bring up the cluster

For KVM/Libvirt environment
```sh
$ vagrant up --provider libvirt
```
For VirtualBox environment
```sh
$ vagrant up
```

### Copy the kubeconfig file from master
Password for root user is _kubeadmin_
```sh
$ mkdir ~/.kube
$ scp root@172.16.16.100:/etc/kubernetes/admin.conf ~/.kube/config
```
### Destroy the cluster
```
$ vagrant destroy -f
```

## Deploying Add Ons
### Deploy dynamic nfs volume provisioning
```sh
$ cd kubernetes/vagrant/misc/nfs-subdir-external-provisioner
$ cat setup_nfs | vagrant ssh kmaster
$ cat setup_nfs | vagrant ssh kworker1
$ cat setup_nfs | vagrant ssh kworker2
$ kubectl create -f 01-setup-nfs-provisioner.yaml

###### for testing
$ kubectl create -f 02-test-claim.yaml
$ kubectl delete -f 02-test-claim.yaml
```
### Deploy metalLB load balancing
```sh
$ cd kubernetes/vagrant-provisioning/misc/metallb
$ kubectl create -f 01_metallb.yaml

###### wait for 10 seconds or so for the pods to run
$ kubectl create -f 02_metallb-config.yaml

###### for testing
$ kubectl create -f 03_test-load-balancer.yaml
$ kubectl delete -f 03_test-load-balancer.yaml
```
