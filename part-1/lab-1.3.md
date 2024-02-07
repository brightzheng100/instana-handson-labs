# Lab 1.3 – Install Instana Server by `stanctl` CLI

## 1. Spin up the VM

```sh
$ cat /etc/os-release
$ uname -a
```

## 2. Check Prerequisites

```sh
# Mount or simply create some data folders for simplicity purposes
$ sudo mkdir -p /mnt/instana/stanctl/{data,metrics,analytics,objects}
```

```sh
# TLS
$ curl -sLO https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
$ chmod +x mkcert-v1.4.3-linux-amd64 && sudo mv mkcert-v1.4.3-linux-amd64 /usr/local/bin/mkcert

# Create a TLS key pair with <INSTANA SERVER IP>.nip.io as its CN
# or skip this if you're going to use your key pair
# NOTE: PLEASE CHANGE TO YOUR IP
$ INSTANA_SERVER_IP=xxx.xxx.xxx.xxx && \
  mkcert -cert-file tls.crt -key-file tls.key "${INSTANA_SERVER_IP}.nip.io" "${INSTANA_SERVER_IP}"

$ ls
```

## 3. Install `stanctl` CLI by Instana Package

```sh
# Replace it with your Instana download key
export INSTANA_DOWNLOAD_KEY=<YOUR_INSTANA_DOWNLOAD_KEY>

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

```sh
sudo sysctl -w fs.inotify.max_user_instances=8192
sudo sysctl -w vm.swappiness=0
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
```

## 4. Install Instana backend

```bash
$ stanctl up
```

## 5. Post Actions

```bash
$ stanctl agent apply
```

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
