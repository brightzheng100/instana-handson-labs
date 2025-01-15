# Lab 1.1 – Install Instana Standard Edition by “stanctl”

## Installation Process – Online Mode

### 1. Spin up the VM

```sh
$ cat /etc/os-release
$ uname -a
```

### 2. Preparing

Create the folders:

```sh
# Mount or simply create some data folders for simplicity purposes
$ sudo mkdir -p /mnt/instana/stanctl/{data,metrics,analytics,objects}
```

Tune OS kernel paramaters:

```sh
# vm.swappiness
$ echo "vm.swappiness=0" | sudo tee -a /etc/sysctl.d/99-stanctl.conf && \
  sudo sysctl -p /etc/sysctl.d/99-stanctl.conf

# fs.inotify.max_user_instances
$ echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.d/99-stanctl.conf && \
  sudo sysctl -p /etc/sysctl.d/99-stanctl.conf

# Transparent Huge Pages
# On Ubuntu or Debian:
sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\".*\)\"/\1 transparent_hugepage=never\"/" "/etc/default/grub"
update-grub
# On RHEL, CentOS Stream, Amazon Linux, or Oracle Linux
sudo grubby --args="transparent_hugepage=never" --update-kernel ALL
```

Restart:
```sh
$ sudo reboot now
```

And check to make sure that **never** is selected by **[]**, as **[never]**, like this:

```sh
$ cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```

If no effect in RHEL, try this:

```sh
# Install tuned & start it if needed
$ sudo yum install tuned
$ sudo systemctl start tuned

# Check current profile. In my case it's "virtual-guest"
$ tuned-adm active
Current active profile: virtual-guest

# Create a dedicated profile folder
$ sudo mkdir /etc/tuned/profile-nothp

# Create a conf which includes the existing profile with `transparent_hugepages=never`
$ cat <<EOF | sudo tee /etc/tuned/profile-nothp/tuned.conf
[main]
include=virtual-guest

[vm]
transparent_hugepages=never
EOF

# Grant execution permission
$ sudo chmod +x /etc/tuned/profile-nothp/tuned.conf

# Activate the profile
$ sudo tuned-adm profile profile-nothp

# Double check the THP setting
$ cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```

Make sure the “/usr/local/bin” is in `$PATH`:

```sh
# Check
$ echo $PATH | grep /usr/local/bin

# Add it in and source it if not
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```


### 3. Install `stanctl` CLI

```sh
# Replace it with your Instana download key
export INSTANA_DOWNLOAD_KEY=<YOUR_INSTANA_DOWNLOAD_KEY>
```

#### When on Ubuntu

```sh
echo 'deb [signed-by=/usr/share/keyrings/instana-archive-keyring.gpg] https://artifact-public.instana.io/artifactory/rel-debian-public-virtual generic main' | sudo tee /etc/apt/sources.list.d/instana-product.list

sudo touch /etc/apt/auth.conf 
cat <<EOF | sudo tee /etc/apt/auth.conf
machine artifact-public.instana.io
  login _
  password $INSTANA_DOWNLOAD_KEY
EOF

wget -qO - --user=_ --password="$INSTANA_DOWNLOAD_KEY" https://artifact-public.instana.io/artifactory/api/security/keypair/public/repositories/rel-debian-public-virtual | gpg --dearmor | sudo tee /usr/share/keyrings/instana-archive-keyring.gpg
```

```sh
sudo apt update -y
sudo apt install -y stanctl
```

#### When on RHEL

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/Instana-Product.repo
[instana-product]
name=Instana-Product
baseurl=https://_:$INSTANA_DOWNLOAD_KEY@artifact-public.instana.io/artifactory/rel-rpm-public-virtual/
enabled=1
gpgcheck=0
gpgkey=https://_:$INSTANA_DOWNLOAD_KEY@artifact-public.instana.io/artifactory/api/security/keypair/public/repositories/rel-rpm-public-virtual
repo_gpgcheck=1
EOF
```

```sh
sudo yum clean expire-cache -y
sudo yum update -y
sudo yum install -y stanctl
```

### 4. Install Instana backend

```bash
$ stanctl --version
```

```sh
sudo dnf install python3-dnf-plugin-versionlock
sudo sudo dnf versionlock add stanctl
```

#### 4.1 Interactive Mode

```sh
$ stanctl up
```

```sh
$ stanctl up --skip-preflight-check
```

#### 4.2 Automated Mode

```sh
$ cat <<EOF > .env
STANCTL_INSTALL_TYPE=demo

STANCTL_DOWNLOAD_KEY=**********************
STANCTL_SALES_KEY=**********************

STANCTL_CORE_BASE_DOMAIN=FQDN, e.g. 162.133.113.4.nip.io
STANCTL_UNIT_TENANT_NAME=Tenant Name, e.g. ibm
STANCTL_UNIT_UNIT_NAME=Tenant Unit Name, e.g. apm
STANCTL_UNIT_INITIAL_ADMIN_PASSWORD=**********

STANCTL_VOLUME_ANALYTICS=/mnt/instana/stanctl/analytics
STANCTL_VOLUME_DATA=/mnt/instana/stanctl/data
STANCTL_VOLUME_METRICS=/mnt/instana/stanctl/metrics
STANCTL_VOLUME_OBJECTS=/mnt/instana/stanctl/objects
EOF
```

```sh
$ stanctl up --skip-preflight-check --core-tls-generate-cert
```

```sh
$ stanctl versions identify

$ cat <<EOF > .env
STANCTL_INSTALL_TYPE=demo
STANCTL_INSTANA_VERSION=3.283.450-0

STANCTL_DOWNLOAD_KEY=**********************
STANCTL_SALES_KEY=**********************

STANCTL_CORE_BASE_DOMAIN=FQDN, e.g. 162.133.113.4.nip.io
STANCTL_UNIT_TENANT_NAME=Tenant Name, e.g. ibm
STANCTL_UNIT_UNIT_NAME=Tenant Unit Name, e.g. apm
STANCTL_UNIT_INITIAL_ADMIN_PASSWORD=**********

STANCTL_VOLUME_ANALYTICS=/mnt/instana/stanctl/analytics
STANCTL_VOLUME_DATA=/mnt/instana/stanctl/data
STANCTL_VOLUME_METRICS=/mnt/instana/stanctl/metrics
STANCTL_VOLUME_OBJECTS=/mnt/instana/stanctl/objects
EOF
```

```sh
$ stanctl up --skip-preflight-check --core-tls-generate-cert
```

### 5. Post Actions

#### 5.1 (Optional) Backend Self-monitoring by Agent

```bash
$ stanctl agent apply
```

#### 5.2 (Optional) Enable Beta / Extensible Features

```sh
$ alias k="k3s kubectl"

$ k get node
$ k describe node <YOUR NODE NAME LISTED BY ABOVE COMMAND>
```

```sh
# Enable Synthetics Monitoring
$ stanctl backend apply --core-feature-flags feature.synthetics.enabled=true

# Enable Logging
$ stanctl backend apply --core-feature-flags feature.logging.enabled=true
```

#### 5.3 (Optional) Change “acceptor” Port?

```sh
$ k get HTTPProxy -n instana-core
$ k get svc -n instana-core
```

```sh
$ k edit -n instana-core svc/instana-core-lb-envoy
$ k get svc -n instana-core | grep LoadBalancer
```

#### 5.4 (Optional) Others

```sh
$ cat <<EOF >> ~/.bashrc
alias k="k3s kubectl"
alias kg="k3s kubectl get"
EOF

$ k get node
```

## Installation Process – Air-gapped Mode

### 0. Prepare in the Bastion Machine

```sh
export INSTANA_DOWNLOAD_KEY=<YOUR INSTANA DOWNLOAD KEY>
export INSTANA_SALES_KEY=<YOUR INSTANA SALES KEY>

stanctl air-gapped package \
  --platform linux/amd64 \
  --download-key=${INSTANA_DOWNLOAD_KEY} \
  --registry-password=${INSTANA_DOWNLOAD_KEY} \
  --sales-key=${INSTANA_SALES_KEY}
```

```sh
$ stanctl versions identify

$ stanctl air-gapped package \
  --platform linux/amd64 \
  --download-key=${INSTANA_DOWNLOAD_KEY} \
  --registry-password=${INSTANA_DOWNLOAD_KEY} \
  --sales-key=${INSTANA_SALES_KEY} \
  --instana-version 3.283.450-0
```

### 3. Installing “stanctl” CLI

```sh
$ tar -zxvf instana-airgapped.tar.gz airgapped/stanctl
$ ls airgapped/

# Move it to the /usr/local/bin/ for convenience
$ sudo chmod +x airgapped/stanctl
$ sudo mv airgapped/stanctl /usr/local/bin/

# Verify it
$ stanctl --version
```

### 4. Importing packages

```sh
$ stanctl air-gapped import -f instana-airgapped.tar.gz
```

### 5. Installing Instana backend

#### 5.1 Interactive Mode

```sh
$ stanctl up --air-gapped
```

```sh
$ stanctl up --air-gapped --skip-preflight-check 
```

#### 5.2 Automated Mode

```sh
$ cat <<EOF > .env
STANCTL_INSTALL_TYPE=demo

STANCTL_DOWNLOAD_KEY=**********************
STANCTL_SALES_KEY=**********************

STANCTL_CORE_BASE_DOMAIN=FQDN, e.g.162.133.113.15.nip.io
STANCTL_UNIT_TENANT_NAME=Tenant Name, e.g. ibm
STANCTL_UNIT_UNIT_NAME=Tenant Unit Name, e.g. prod
STANCTL_UNIT_INITIAL_ADMIN_PASSWORD=**********

STANCTL_VOLUME_ANALYTICS=/mnt/instana/stanctl/analytics
STANCTL_VOLUME_DATA=/mnt/instana/stanctl/data
STANCTL_VOLUME_METRICS=/mnt/instana/stanctl/metrics
STANCTL_VOLUME_OBJECTS=/mnt/instana/stanctl/objects
EOF

$ stanctl up --air-gapped --skip-preflight-check --core-tls-generate-cert
```

## Annex

### TLS Certs

```sh
# TLS
$ curl -sLO https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
$ chmod +x mkcert-v1.4.3-linux-amd64 && sudo mv mkcert-v1.4.3-linux-amd64 /usr/local/bin/mkcert

# Create a TLS key pair with <INSTANA SERVER IP>.nip.io as its CN
# or skip this if you're going to use your key pair
# NOTE: PLEASE CHANGE TO YOUR IP
$ INSTANA_SERVER_IP=162.133.113.8 && \
  mkcert -cert-file tls.crt -key-file tls.key "${INSTANA_SERVER_IP}.nip.io" "${INSTANA_SERVER_IP}"
```

### Clean Up

```sh
# Clean up K8s objects and K8s itself
$ k3s-uninstall.sh

# Clean up config files
$ rm -rf ~/.stanctl

# Clean up data files
$ sudo rm -rf /mnt/instana
```
