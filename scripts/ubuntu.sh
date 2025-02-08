#!/bin/bash

##
#
# Note: this file is just the "overlay" of bootstrap-k8s-on-rhel.sh
# for necessary we need to make on Ubuntu
#
##

### Installing K8s tools
function installing-k8s-tools {
  echo "----> installing-k8s-tools"

  sudo apt-get install -y apt-transport-https ca-certificates curl gpg

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update

  # Check the available candidates by:
  #  sudo apt-cache madison kubelet
  #  sudo apt-cache madison kubeadm
  #  sudo apt-cache madison kubectl
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl

  # Enable kubelet
  sudo systemctl enable kubelet
  
  logme "$color_green" "DONE"
}

### Installing K8s CRI with CRI-O
function installing-k8s-cri {
  echo "----> installing-k8s-cri"

  # Ref: https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems

  # As per the official doc (https://cri-o.io/), there are different path for different Ubuntu version, sigh!
  # OS="Debian_Unstable"
  # if [[ $(lsb_release -rs) == "18.04" ]]; then
  #   OS="xUbuntu_18.04"
  # elif [[ $(lsb_release -rs) == "19.04" ]]; then
  #   OS="xUbuntu_19.04"
  # elif [[ $(lsb_release -rs) == "19.10" ]]; then
  #   OS="xUbuntu_19.10"
  # elif [[ $(lsb_release -rs) == "20.04" ]]; then
  #   OS="xUbuntu_20.04"
  # elif [[ $(lsb_release -rs) == "21.10" ]]; then
  #   OS="xUbuntu_21.10"
  # elif [[ $(lsb_release -rs) == "22.04" ]]; then
  #   OS="xUbuntu_22.04"
  # fi
  # echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
  # echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
  # curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
  # curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

  curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v$CRIO_VERSION/deb/Release.key |
      sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

  echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v$CRIO_VERSION/deb/ /" |
      sudo tee /etc/apt/sources.list.d/cri-o.list

  sudo apt-get update
  sudo apt-get install cri-o -y

  # Enable and start cri-o service
  sudo systemctl enable crio
  sudo systemctl start crio
  
  logme "$color_green" "DONE"
}

### Bootstrapping K8s

### Getting ready with K8s

### Installing K8s CNI with Calico

### Installing local-path-provisioner

### Preparing join node into the cluster
