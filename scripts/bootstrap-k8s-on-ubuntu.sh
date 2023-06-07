#!/bin/bash

source utils.sh
source bootstrap-k8s-on-rhel.sh


##
#
# Note: this file is just the "overlay" of bootstrap-k8s-on-rhel.sh
# for necessary we need to make on Ubuntu
#
##

### Installing K8s tools
function installing-k8s-tools {
  echo "----> installing-k8s-tools"

  sudo apt-get install -y ca-certificates curl

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update

  # Check the available candidates by:
  #  sudo apt-cache madison kubelet
  #  sudo apt-cache madison kubeadm
  #  sudo apt-cache madison kubectl
  sudo apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION

  # Enable kubelet
  sudo systemctl enable kubelet
  
  logme "$color_green" "DONE"
}

### Installing K8s CRI with CRI-O
function installing-k8s-cri {
  echo "----> installing-k8s-cri"

  # As per the official doc (https://cri-o.io/), there are different path for different Ubuntu version, sigh!
  OS="Debian_Unstable"
  if [[ $(lsb_release -rs) == "18.04" ]]; then
    OS="xUbuntu_18.04"
  elif [[ $(lsb_release -rs) == "19.04" ]]; then
    OS="xUbuntu_19.04"
  elif [[ $(lsb_release -rs) == "19.10" ]]; then
    OS="xUbuntu_19.10"
  elif [[ $(lsb_release -rs) == "20.04" ]]; then
    OS="xUbuntu_20.04"
  fi
  echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
  echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

  sudo apt-get update
  sudo apt-get install cri-o cri-o-runc -y

  # Enable and start cri-o service
  sudo systemctl enable crio
  sudo systemctl start crio
  
  logme "$color_green" "DONE"
}

### Bootstrapping K8s

### Getting ready with K8s

### Installing K8s CNI with Calico

### Installing local-path-provisioner


## ----------------------------------------------------------------------------------------


# Export the vars before running the scripts, for example:
#
# export K8S_VERSION="1.26.3-00"
# export CRIO_VERSION="1.26"
# export CALICO_MANIFEST_FILE="https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"
#
# And the script will respect it, or the default value applies
export_var_with_default "K8S_VERSION" "1.26.3-00"
export_var_with_default "CRIO_VERSION" "1.26"
export_var_with_default "CALICO_MANIFEST_FILE" "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"


# Orchestrate the process
echo "#################################################"

installing-k8s-tools
installing-k8s-cri

bootstrapping-k8s
progress-bar 1

getting-ready-k8s
installing-k8s-cni

installing-local-path-provisioner
