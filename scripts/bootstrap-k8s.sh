#!/bin/bash

source utils.sh

source /etc/os-release
case $ID in
  rhel) 
    # RHEL
    logme "$color_green" "RHEL OS detected"
    source rhel.sh
    ;;
  centos) 
    # CentOS
    logme "$color_green" "CentOS OS detected"
    source rhel.sh
    ;;
  ubuntu) 
    # Ubuntu
    logme "$color_green" "Ubuntu OS detected"
    source rhel.sh
    source ubuntu.sh
    ;;
  *) 
    # Others
    logme "$color_red" "!!! Unsupported OS detected: $ID !!!"
    return 0
    ;;
esac

## ----------------------------------------------------------------------------------------


# Export the vars before running the scripts, for example:
#
# export K8S_VERSION="1.30"
# export CRIO_VERSION="1.30"
# export CALICO_MANIFEST_FILE="https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"
#
# And the script will respect it, or the default value applies
export_var_with_default "K8S_VERSION" "1.30"
export_var_with_default "CRIO_VERSION" "1.30"
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
