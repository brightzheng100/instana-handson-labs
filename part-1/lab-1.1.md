# Lab 1.1 – Install Instana Server Manually

## 1. Spin up the VM

```sh
$ cat /etc/os-release

$ uname -a
```

## 2. Check Prerequisites

```sh
# Test the connectivity
# Make sure the netcat is installed
$ sudo dnf install nc -y
$ nc -vz auth-infra.instana.io 443

# Mount or simply create some data folders for simplicity purposes
$ sudo mkdir /mnt/{data,metrics,traces}

# TLS
$ curl -sLO https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
$ chmod +x mkcert-v1.4.3-linux-amd64 && sudo mv mkcert-v1.4.3-linux-amd64 /usr/local/bin/mkcert

# Create a TLS key pair with <INSTANA SERVER IP>.nip.io as its CN
# or skip this if you're going to use your key pair
# NOTE: PLEASE CHANGE TO YOUR IP
$ INSTANA_SERVER_IP=168.1.53.231 && \
  mkcert -cert-file tls.crt -key-file tls.key "${INSTANA_SERVER_IP}.nip.io" "${INSTANA_SERVER_IP}"
```

## 3. Install Docker

```sh
# Remove some legacy components, if any
sudo dnf remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc

# Add Docker CE's repo and install Docker CE
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start Docker daemon process
sudo systemctl enable docker
sudo systemctl start docker

# Have a try for Docker
sudo docker run hello-world

# Add current user into docker group so that we can run Docker cli without the need of sudo
sudo usermod -aG docker $USER
```

> Note: Please re-login to the VM to take effect.

## 4. Install Instana Server

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/Instana-Product.repo
[instana-product]
name=Instana-Product
baseurl=https://self-hosted.instana.io/rpm/release/product/rpm/generic/x86_64/Packages
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://self-hosted.instana.io/signing_key.gpg
priority=5
sslverify=1
#proxy=http://x.x.x.x:8080
#proxy_username=
#proxy_password=
EOF

sudo dnf makecache -y
sudo dnf install -y instana-console

instana version

sudo dnf install python3-dnf-plugin-versionlock -y
sudo dnf versionlock add instana-console

# Finally, let’s kick off the init process
sudo instana init
```

## 5. First login


## 6. License

```sh
# Download license
$ sudo instana license download

# Now import it
$ sudo instana license import -f license

# And verify it
$ sudo instana license verify
```

## 7. Post Actions

After installing the agent by running the generated one-liner command from Instana UI:

```sh
$ sudo systemctl is-enabled instana-agent

# Or we can enable and start it manually
$ sudo systemctl enable instana-agent
$ sudo systemctl start instana-agent

$ sudo systemctl status instana-agent

# Configure zone
sudo touch /opt/instana/agent/etc/instana/configuration-zone.yaml

INSTANA_ZONE="InstanaServer" && \
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-zone.yaml
# Hardware & Zone
com.instana.plugin.generic.hardware:
  enabled: true
  availability-zone: "${INSTANA_ZONE}"
EOF

# (optional) Configure host, like tags
# Do change them accordingly
sudo touch /opt/instana/agent/etc/instana/configuration-host.yaml

cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-host.yaml
# Host
com.instana.plugin.host:
  tags:
    - 'poc'
    - 'instana'
EOF
```

```sh
# Set up the proper EUM endpoint which will proxy to the :2999 internal port
# DO REPLACE IT WITH YOUR ENDPOINT!!!
# Ref: https://www.ibm.com/docs/en/obi/current?topic=installer-configuring-end-user-monitoring
EUM_ENDPOINT="https://168.1.53.216.nip.io:446" && \
cat | sudo tee -a settings.hcl <<EOF
eum {
  tracking_base_url = "${EUM_ENDPOINT}/eum/"
}
EOF

# Then apply it
sudo instana update -f settings.hcl
```
