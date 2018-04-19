#!/bin/bash

# Setup vagrant.
echo "Setup vagrant"
vagrant destroy
vagrant up --provider virtualbox
vagrant ssh -c "echo export HUB=10.10.0.2:5000 >> ~/.bashrc"
vagrant ssh -c "echo export TAG=latest >> ~/.bashrc"
vagrant ssh -c "source ~/.bashrc"

# Setting up kubernetest Cluster on VM for Istio Tests.
echo "Adding priviledges to kubernetes cluster..."
vagrant ssh -c "sudo sed -i 's/ExecStart=\/usr\/bin\/hyperkube kubelet/ExecStart=\/usr\/bin\/hyperkube kubelet --allow-privileged=true/' /etc/systemd/system/kubelet.service"
vagrant ssh -c "sudo systemctl daemon-reload"
vagrant ssh -c "sudo systemctl stop kubelet"
vagrant ssh -c "sudo systemctl restart kubelet.service"
vagrant ssh -c "sudo sed -i 's/ExecStart=\/usr\/bin\/hyperkube apiserver/ExecStart=\/usr\/bin\/hyperkube apiserver --allow-privileged=true/' /etc/systemd/system/kube-apiserver.service"
vagrant ssh -c "sudo sed -i 's/--admission-control=AlwaysAdmit,ServiceAccount/--admission-control=AlwaysAdmit,NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota/'  /etc/systemd/system/kube-apiserver.service"
vagrant ssh -c "sudo systemctl daemon-reload"
vagrant ssh -c "sudo systemctl stop kube-apiserver"
vagrant ssh -c "sudo systemctl restart kube-apiserver"
vagrant reload
vagrant ssh -c "kubectl get pods -n kube-system"
