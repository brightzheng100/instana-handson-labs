# Preparing the “manage-to” Host, on Ubuntu

## Install Docker

```sh
# Install 
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    
# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   
# Install Docker engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Post-installation steps for Linux
sudo usermod -aG docker $USER
```

Re-login to the VM and try:

```sh
# Try running docker without sudo
docker run hello-world
```

## Install necessary tools

1. Install “kind” – it’s a tool for creating Kubernetes in Docker, that why it’s called “kind”:

```sh
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.19.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

```sh
# Check the version
# Should see something like: 
# kind v0.19.0 go1.19.1 linux/amd64
kind --version
```

2. Install “footloose” – it’s a tool to spin up “VMs” as Docker containers:

```sh
curl -Lo footloose https://github.com/weaveworks/footloose/releases/download/0.6.3/footloose-0.6.3-linux-x86_64
chmod +x footloose
sudo mv footloose /usr/local/bin/
```

```sh
# Check the version
# Should see something like: 
# version: 0.6.3
footloose version
```

3. Other tools

```sh
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

```sh
# Check the version
# should see output like: 
# Client Version: v1.25.2
# Kustomize Version: v4.5.7
kubectl version --short --client
```

```sh
# Helm CLI
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
```

```sh
# Check the version
# should see output like: 
# v3.9.4+gdbc6d8e
helm version --short
```

## Spin up Kubernetes cluster

```sh
# Customize a kind-config.yaml file with 1 master 3 worker nodes
# You may spin up a minium cluster simply by: kind create cluster
$ cat > kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

# Create the cluster using the file
# This make take a 2-10 minutes depending on your download speed
$ kind create cluster --config kind-config.yaml
```

Output:

```sh
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.25.2) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```

```sh
# Verify the cluster
# Note: the nodes might be in “NotReady”, just wait for a while
$ kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   83s   v1.25.2
kind-worker          Ready    <none>          51s   v1.25.2
kind-worker2         Ready    <none>          51s   v1.25.2
kind-worker3         Ready    <none>          64s   v1.25.2
```

## Spin up “VM”s

```sh
Create a YAML to define our VMs
$ cat > footloose.yaml <<EOF
cluster:
  name: labs
  privateKey: labs-key
machines:
- count: 1
  spec:
    image: quay.io/footloose/ubuntu18.04
    name: ubuntu-%d
    networks:
    - footloose-cluster
    portMappings:
    - containerPort: 22
    privileged: true
    volumes:
    - type: volume
      destination: /var
- count: 1
  spec:
    image: quay.io/footloose/centos7
    name: centos-%d
    networks:
    - footloose-cluster
    portMappings:
    - containerPort: 22
    privileged: true
    volumes:
    - type: volume
      destination: /var
EOF

# Create a dedicated Docker network
$ docker network create footloose-cluster

# Spin up VMs
$ footloose create -c footloose.yaml
INFO[0000] Docker Image: quay.io/footloose/ubuntu18.04 present locally
INFO[0000] Docker Image: quay.io/footloose/centos7 present locally
INFO[0000] Creating machine: labs-ubuntu-0 ...
INFO[0000] Connecting labs-ubuntu-0 to the footloose-cluster network...
INFO[0001] Creating machine: labs-centos-0 ...
INFO[0001] Connecting labs-centos-0 to the footloose-cluster network...

# Check it out
$ footloose show -c footloose.yaml
NAME            HOSTNAME   PORTS           IP   IMAGE                           CMD          STATE     BACKEND
labs-ubuntu-0   ubuntu-0   0->{22 49154}        quay.io/footloose/ubuntu18.04   /sbin/init   Running
labs-centos-0   centos-0   0->{22 49155}        quay.io/footloose/centos7       /sbin/init   Running

# Log into any of the VMs
$ footloose ssh root@ubuntu-0 -c footloose.yaml
Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 4.15.0-144-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@ubuntu-0:~# exit

```
